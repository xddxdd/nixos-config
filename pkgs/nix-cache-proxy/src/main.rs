mod config;
mod proxy;
mod url_rewriter;

use anyhow::Result;
use axum::{
    extract::{Path, State},
    routing::get,
    Router,
};
use config::Config;
use proxy::AppState;
use std::sync::Arc;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize logging
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "nix_cache_proxy=info,tower_http=info".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Load configuration from CLI arguments
    let config = Config::parse_args()?;
    tracing::info!("Loaded configuration: {:?}", config);

    // Create shared state
    let state = AppState {
        config: Arc::new(config.clone()),
        client: reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(config.timeout_secs))
            .build()?,
    };

    // Build router
    let app = Router::new()
        .route("/{*path}", get(handle_request))
        .with_state(state);

    // Create listener based on configuration
    match &config.listen_mode {
        config::ListenMode::Tcp(addr) => {
            let listener = tokio::net::TcpListener::bind(addr).await?;
            tracing::info!("Nix cache proxy listening on {}", addr);
            axum::serve(listener, app).await?;
        }
        config::ListenMode::Unix(path) => {
            // Remove existing socket file if it exists
            if path.exists() {
                std::fs::remove_file(path)?;
            }

            let listener = tokio::net::UnixListener::bind(path)?;
            tracing::info!(
                "Nix cache proxy listening on unix socket: {}",
                path.display()
            );

            axum::serve(listener, app).await?;

            // Cleanup socket file on exit
            if path.exists() {
                std::fs::remove_file(path)?;
            }
        }
        config::ListenMode::Systemd => {
            let mut listenfd = listenfd::ListenFd::from_env();

            if let Ok(Some(listener)) = listenfd.take_tcp_listener(0) {
                // Convert std::net::TcpListener to tokio::net::TcpListener
                listener.set_nonblocking(true)?;
                let listener = tokio::net::TcpListener::from_std(listener)?;

                tracing::info!("Nix cache proxy using systemd socket activation");
                axum::serve(listener, app).await?;
            } else {
                anyhow::bail!(
                    "No systemd socket found. Make sure to run with systemd socket activation."
                );
            }
        }
    }

    Ok(())
}

async fn handle_request(
    State(state): State<AppState>,
    Path(path): Path<String>,
) -> impl axum::response::IntoResponse {
    tracing::info!("Received request for: {}", path);
    proxy::proxy_handler(State(state), path).await
}
