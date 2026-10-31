mod compress;

use clap::Parser;
use std::fs;
use walkdir::WalkDir;

const COMPRESSED_EXTS: &[&str] = &["gz", "br", "zstd"];

#[derive(Parser, Debug, Clone)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Folder to compress
    #[arg(short, long)]
    target: String,

    /// Extensions to be compressed
    #[arg(
        short,
        long,
        default_value = "htm,html,css,js,atom,stl,xml,svg,json,txt"
    )]
    include_ext: String,

    /// Extensions to be not compressed
    #[arg(short, long, default_value = "")]
    exclude_ext: String,

    /// Enable Gzip compression
    #[arg(short, long, default_value_t = true)]
    gzip: bool,

    /// Enable Brotli compression
    #[arg(short, long, default_value_t = true)]
    brotli: bool,

    /// Enable Zstd compression
    #[arg(short, long, default_value_t = true)]
    zstd: bool,
}

fn main() {
    let args = Args::parse();

    let dir = fs::canonicalize(args.target.clone())
        .unwrap()
        .to_str()
        .unwrap()
        .to_owned();

    iterate_directory(dir, &args);
}

fn is_compressed(file: &String) -> bool {
    return has_extension(file, &COMPRESSED_EXTS.iter().map(|s| *s).collect());
}

fn has_extension(file: &String, exts: &Vec<&str>) -> bool {
    return exts.iter().any(|e| {
        file.to_lowercase()
            .ends_with(&format!(".{}", e.to_lowercase()))
    });
}

fn iterate_directory(dir: String, args: &Args) {
    let include_exts: Vec<&str> = args
        .include_ext
        .split(",")
        .filter(|s| !s.is_empty())
        .collect();
    let exclude_exts: Vec<&str> = args
        .exclude_ext
        .split(",")
        .filter(|s| !s.is_empty())
        .collect();
    println!("Included extensions: {}", include_exts.join(", "));
    println!("Excluded extensions: {}", exclude_exts.join(", "));

    rayon::scope(|scope| {
        println!("Scanning {:?}", dir);
        let walker = WalkDir::new(dir)
            .into_iter()
            .filter_entry(|e| !is_compressed(&e.path().to_str().unwrap().to_owned()));

        for it in walker {
            let entry = it.unwrap();
            let path = entry.path().to_str().unwrap().to_owned();

            if !entry.file_type().is_file() {
                continue;
            }

            if !include_exts.is_empty() && !has_extension(&path, &include_exts) {
                println!("Skipped {} for not the file type to include", path.clone());
                continue;
            }

            if !exclude_exts.is_empty() && has_extension(&path, &exclude_exts) {
                println!("Skipped {} for being file type to exclude", path.clone());
                continue;
            }

            scope.spawn(move |_| {
                let mut max_size = match compress::file_size(path.clone()) {
                    Ok(len) => len,
                    Err(e) => {
                        println!("Error processing {}: {}", path.clone(), e.to_string());
                        return;
                    }
                };

                // Sorted by browser compatibility, prefer older format if smaller
                if args.gzip {
                    let size = compress::gzip(path.clone(), max_size).unwrap();
                    max_size = std::cmp::min(max_size, size);
                }
                if args.brotli {
                    let size = compress::brotli(path.clone(), max_size).unwrap();
                    max_size = std::cmp::min(max_size, size);
                }
                if args.zstd {
                    let size = compress::zstd(path.clone(), max_size).unwrap();
                    max_size = std::cmp::min(max_size, size);
                }

                // Suppress unused code warning
                let _ = max_size;
            });
        }
    });
}
