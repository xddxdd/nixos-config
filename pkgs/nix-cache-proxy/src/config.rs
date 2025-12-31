use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use url::Url;

/// A caching proxy for Nix binary caches
#[derive(Parser, Debug, Clone)]
#[command(name = "nix-cache-proxy")]
#[command(about = "Proxy for Nix binary caches", long_about = None)]
pub struct Config {
    /// Bind address (TCP: 127.0.0.1:8080, Unix: unix:/path/to/socket.sock, Systemd: systemd)
    #[arg(short, long, default_value = "127.0.0.1:8080")]
    bind: String,

    /// Upstream cache URLs (can be specified multiple times)
    #[arg(short, long, default_value = "https://cache.nixos.org")]
    upstream: Vec<String>,

    /// Request timeout in seconds
    #[arg(short, long, default_value_t = 5)]
    pub timeout_secs: u64,

    #[clap(skip)]
    pub listen_mode: ListenMode,

    #[clap(skip)]
    pub upstreams: Vec<Url>,
}

#[derive(Debug, Clone)]
pub enum ListenMode {
    Tcp(String),
    Unix(PathBuf),
    Systemd,
}

impl Default for ListenMode {
    fn default() -> Self {
        ListenMode::Tcp(String::new())
    }
}

impl Config {
    /// Parse CLI arguments and validate configuration
    pub fn parse_args() -> Result<Self> {
        let mut config = Config::parse();

        // Parse the bind address to determine the listen mode
        config.listen_mode = if config.bind == "systemd" {
            ListenMode::Systemd
        } else if let Some(path) = config.bind.strip_prefix("unix:") {
            ListenMode::Unix(PathBuf::from(path))
        } else {
            ListenMode::Tcp(config.bind.clone())
        };

        // Parse upstream URLs
        config.upstreams = config
            .upstream
            .iter()
            .map(|s| {
                Url::parse(s).map_err(|e| anyhow::anyhow!("Invalid upstream URL '{}': {}", s, e))
            })
            .collect::<Result<Vec<Url>>>()?;

        Ok(config)
    }
}
