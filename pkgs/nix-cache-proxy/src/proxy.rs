use crate::config::Config;
use crate::url_rewriter::rewrite_narinfo_url;
use anyhow::Result;
use axum::{
    body::Body,
    extract::State,
    http::{Response, StatusCode},
    response::IntoResponse,
};
use std::collections::VecDeque;
use std::sync::Arc;

#[derive(Clone)]
pub struct AppState {
    pub config: Arc<Config>,
    pub client: reqwest::Client,
}

/// Proxy handler for .narinfo requests
pub async fn proxy_handler(State(state): State<AppState>, path: String) -> impl IntoResponse {
    match proxy_request(&state, &path).await {
        Ok(response) => response,
        Err(e) => {
            tracing::error!("Proxy error: {}", e);
            Response::builder()
                .status(StatusCode::BAD_GATEWAY)
                .body(Body::from(format!("Proxy error: {}", e)))
                .unwrap()
        }
    }
}

async fn proxy_request(state: &AppState, path: &str) -> Result<Response<Body>> {
    // Spawn parallel requests to all upstreams and collect their handles in a queue
    let mut handles = VecDeque::new();

    // Spawn parallel requests to all upstreams
    for upstream in state.config.upstreams.iter() {
        let upstream = upstream.clone();
        let path = path.to_string();
        let client = state.client.clone();

        let handle = tokio::spawn(async move {
            let url = upstream.join(&path)?;
            tracing::debug!("Requesting from upstream {}: {}", upstream, url);

            let response = client.get(url.as_str()).send().await?;
            let status = response.status();

            if status.is_success() {
                let body = response.text().await?;
                Ok::<_, anyhow::Error>(Some((upstream, body)))
            } else {
                tracing::debug!("Upstream {} returned status {}", upstream, status);
                Ok(None)
            }
        });

        handles.push_back(handle);
    }

    // Wait for handles in order (pop from front of queue)
    while let Some(handle) = handles.pop_front() {
        match handle.await {
            Ok(Ok(Some((upstream, body)))) => {
                tracing::debug!("Upstream {} succeeded", upstream);

                // Rewrite URLs in the response
                let rewritten_body = rewrite_narinfo_url(&body, &upstream)?;

                tracing::info!("Returning response from upstream: {}", upstream);

                return Ok(Response::builder()
                    .status(StatusCode::OK)
                    .header("Content-Type", "text/x-nix-narinfo")
                    .body(Body::from(rewritten_body))?);
            }
            Ok(Ok(None)) => {
                // Upstream returned non-success, continue to next
            }
            Ok(Err(e)) => {
                tracing::warn!("Upstream request failed: {}", e);
            }
            Err(e) => {
                tracing::warn!("Task join error: {}", e);
            }
        }
    }

    // No successful responses from any upstream
    Ok(Response::builder()
        .status(StatusCode::NOT_FOUND)
        .body(Body::from("No upstream returned a successful response"))?)
}
