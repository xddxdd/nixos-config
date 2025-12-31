mod config;
mod listener;
mod proxy;
mod url_rewriter;

use anyhow::Result;
use config::Config;
use listener::serve_connections;
use proxy::AppState;
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize logging
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();

    // Load configuration from CLI arguments
    let config = Config::parse_args()?;
    log::info!("Loaded configuration: {:?}", config);

    // Create shared state
    let https = hyper_rustls::HttpsConnectorBuilder::new()
        .with_webpki_roots()
        .https_or_http()
        .enable_http1()
        .build();

    let client = hyper_util::client::legacy::Client::builder(hyper_util::rt::TokioExecutor::new())
        .build(https);

    let state = AppState {
        config: Arc::new(config.clone()),
        client,
    };

    // Create listener based on configuration
    match &config.listen_mode {
        config::ListenMode::Tcp(addr) => {
            let listener = tokio::net::TcpListener::bind(addr).await?;
            log::info!("Nix cache proxy listening on {}", addr);
            serve_connections(listener, state).await
        }
        config::ListenMode::Unix(path) => {
            // Remove existing socket file if it exists
            if path.exists() {
                std::fs::remove_file(path)?;
            }

            let listener = tokio::net::UnixListener::bind(path)?;
            log::info!(
                "Nix cache proxy listening on unix socket: {}",
                path.display()
            );
            serve_connections(listener, state).await
        }
        config::ListenMode::Systemd => {
            let mut listenfd = listenfd::ListenFd::from_env();

            if let Ok(Some(listener)) = listenfd.take_tcp_listener(0) {
                // Convert std::net::TcpListener to tokio::net::TcpListener
                listener.set_nonblocking(true)?;
                let listener = tokio::net::TcpListener::from_std(listener)?;

                log::info!("Nix cache proxy using systemd socket activation");
                serve_connections(listener, state).await
            } else {
                anyhow::bail!(
                    "No systemd socket found. Make sure to run with systemd socket activation."
                );
            }
        }
    }
}
