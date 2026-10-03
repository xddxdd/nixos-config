//! fastpit: deterministic, corpus-driven LLM tarpit HTTP server.

mod app;
mod assets;
mod corpus;
mod mmap;
mod page;
mod rng;

use std::path::{Path, PathBuf};
use std::os::unix::fs::PermissionsExt;
use std::sync::Arc;

use axum::Router;

use crate::app::{handle, App, Config};
use crate::assets::Assets;
use crate::corpus::Corpus;
use crate::page::normalize_doc_root;

fn usage() -> String {
    "\
fastpit - deterministic LLM tarpit

Usage: fastpit [OPTIONS]

Options:
  --host <ip>              bind address (default 127.0.0.1)
  --port <u16>             bind port (default 8080)
  --socket <path>          bind a unix socket instead of TCP
  --seed <u64>             global seed / salt (default 0)
  --document-root <path>   sub-path deployment prefix (default /)
  --workers <n>            tokio worker threads, 0 = available_parallelism (default 0)
  --cache-size <n>         max cached pages, 0 disables (default 2048)
  --asset-dir <path>       directory of assets (default assets)
  --data-file <path>       mmap a packed corpus.bin instead of the embedded corpus
  --help                   show this help
"
    .to_string()
}

fn next_value(args: &mut impl Iterator<Item = String>, flag: &str) -> String {
    match args.next() {
        Some(value) => value,
        None => {
            eprintln!("error: missing value for {}", flag);
            eprint!("{}", usage());
            std::process::exit(2);
        }
    }
}

fn parse_value<T: std::str::FromStr>(flag: &str, value: String) -> T {
    match value.parse() {
        Ok(parsed) => parsed,
        Err(_) => {
            eprintln!("error: invalid value for {}: {}", flag, value);
            eprint!("{}", usage());
            std::process::exit(2);
        }
    }
}

fn parse_args() -> Config {
    let mut host = "127.0.0.1".to_string();
    let mut port: u16 = 8080;
    let mut socket: Option<PathBuf> = None;
    let mut seed: u64 = 0;
    let mut doc_root = "/".to_string();
    let mut workers: usize = 0;
    let mut cache_size: usize = 2048;
    let mut asset_dir = "assets".to_string();
    let mut data_file: Option<PathBuf> = None;

    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--help" | "-h" => {
                print!("{}", usage());
                std::process::exit(0);
            }
            "--host" => host = next_value(&mut args, &arg),
            "--port" => port = parse_value(&arg, next_value(&mut args, &arg)),
            "--socket" => socket = Some(PathBuf::from(next_value(&mut args, &arg))),
            "--seed" => seed = parse_value(&arg, next_value(&mut args, &arg)),
            "--document-root" => doc_root = next_value(&mut args, &arg),
            "--workers" => workers = parse_value(&arg, next_value(&mut args, &arg)),
            "--cache-size" => cache_size = parse_value(&arg, next_value(&mut args, &arg)),
            "--asset-dir" => asset_dir = next_value(&mut args, &arg),
            "--data-file" => data_file = Some(PathBuf::from(next_value(&mut args, &arg))),
            other => {
                eprintln!("error: unknown argument: {}", other);
                eprint!("{}", usage());
                std::process::exit(2);
            }
        }
    }

    Config {
        host,
        port,
        socket,
        seed,
        doc_root: normalize_doc_root(&doc_root),
        workers,
        cache_size,
        asset_dir,
        data_file,
    }
}

fn main() {
    let config = parse_args();

    let assets = match Assets::from_dir(Path::new(&config.asset_dir)) {
        Ok(assets) => assets,
        Err(err) => {
            eprintln!("error: failed to load assets: {}", err);
            std::process::exit(1);
        }
    };

    let corpus = if let Some(file) = config.data_file.as_deref() {
        match Corpus::from_file(file) {
            Ok(corpus) => corpus,
            Err(err) => {
                eprintln!("error: failed to load corpus: {}", err);
                std::process::exit(1);
            }
        }
    } else {
        Corpus::embedded()
    };

    let workers = if config.workers == 0 {
        std::thread::available_parallelism()
            .map(|n| n.get())
            .unwrap_or(1)
    } else {
        config.workers
    };

    let runtime = tokio::runtime::Builder::new_multi_thread()
        .worker_threads(workers)
        .enable_all()
        .build()
        .expect("failed to build tokio runtime");

    let host = config.host.clone();
    let port = config.port;
    let socket = config.socket.clone();
    let seed = config.seed;
    let cache_size = config.cache_size;
    let asset_extensions = assets.extensions().collect::<Vec<_>>().join(",");
    let app = Arc::new(App::new(corpus, assets, config));

    runtime.block_on(async move {
        let app_router = Router::new().fallback(handle).with_state(app);

        if let Some(path) = socket {
            // A previous run may have left a stale socket file at this path.
            let _ = std::fs::remove_file(&path);
            let listener = match tokio::net::UnixListener::bind(&path) {
                Ok(listener) => listener,
                Err(err) => {
                    eprintln!("error: cannot bind unix socket {}: {}", path.display(), err);
                    std::process::exit(1);
                }
            };

            // Best-effort: the socket is usable even if its mode cannot be set.
            let _ = std::fs::set_permissions(&path, std::fs::Permissions::from_mode(0o770));

            println!(
                "fastpit listening on unix:{} (seed={}, workers={}, cache-size={}, assets={})",
                path.display(), seed, workers, cache_size, asset_extensions
            );

            if let Err(err) = axum::serve(listener, app_router).await {
                eprintln!("error: server stopped: {}", err);
                std::process::exit(1);
            }
            return;
        }

        let listener = match tokio::net::TcpListener::bind((host.as_str(), port)).await {
            Ok(listener) => listener,
            Err(err) => {
                eprintln!("error: cannot bind {}:{}: {}", host, port, err);
                std::process::exit(1);
            }
        };
        let addr = listener
            .local_addr()
            .map(|a| a.to_string())
            .unwrap_or_else(|_| format!("{}:{}", host, port));
        println!(
            "fastpit listening on http://{} (seed={}, workers={}, cache-size={}, assets={})",
            addr, seed, workers, cache_size, asset_extensions
        );

        if let Err(err) = axum::serve(listener, app_router).await {
            eprintln!("error: server stopped: {}", err);
            std::process::exit(1);
        }
    });
}
