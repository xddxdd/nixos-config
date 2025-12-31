use crate::config::Config;
use crate::url_rewriter::rewrite_narinfo_url;
use anyhow::Result;
use http_body_util::{BodyExt, Empty, Full};
use hyper::body::Bytes;
use hyper::{Request, Response, StatusCode};
use hyper_util::client::legacy::Client;
use std::collections::VecDeque;
use std::sync::Arc;

type HttpClient = Client<
    hyper_rustls::HttpsConnector<hyper_util::client::legacy::connect::HttpConnector>,
    Empty<Bytes>,
>;

#[derive(Clone)]
pub struct AppState {
    pub config: Arc<Config>,
    pub client: HttpClient,
}

/// Proxy handler for .narinfo requests
pub async fn proxy_handler(state: AppState, path: String) -> Response<Full<Bytes>> {
    match proxy_request(&state, &path).await {
        Ok(response) => response,
        Err(e) => {
            log::error!("Proxy error: {}", e);
            Response::builder()
                .status(StatusCode::BAD_GATEWAY)
                .body(Full::new(Bytes::from(format!("Proxy error: {}", e))))
                .unwrap()
        }
    }
}

async fn proxy_request(state: &AppState, path: &str) -> Result<Response<Full<Bytes>>> {
    // Spawn parallel requests to all upstreams and collect their handles in a queue
    let mut handles = VecDeque::new();

    // Spawn parallel requests to all upstreams
    for upstream in state.config.upstreams.iter() {
        let upstream = upstream.clone();
        let path = path.to_string();
        let client = state.client.clone();

        let handle = tokio::spawn(async move {
            let url = upstream.join(&path)?;
            log::debug!("Requesting from upstream {}: {}", upstream, url);

            let uri: hyper::Uri = url.as_str().parse()?;
            let request = Request::builder().uri(uri).body(Empty::<Bytes>::new())?;

            let response = client.request(request).await;

            match response {
                Ok(resp) if resp.status() == StatusCode::OK => {
                    let body_bytes = resp.into_body().collect().await?.to_bytes();
                    let body = String::from_utf8(body_bytes.to_vec())?;
                    Ok::<_, anyhow::Error>(Some((upstream, body)))
                }
                Ok(resp) => {
                    log::debug!("Upstream {} returned status {}", upstream, resp.status());
                    Ok(None)
                }
                Err(e) => {
                    log::debug!("Upstream {} request failed: {}", upstream, e);
                    Ok(None)
                }
            }
        });

        handles.push_back(handle);
    }

    // Wait for handles in order (pop from front of queue)
    while let Some(handle) = handles.pop_front() {
        match handle.await {
            Ok(Ok(Some((upstream, body)))) => {
                log::debug!("Upstream {} succeeded", upstream);

                // Rewrite URLs in the response
                let rewritten_body = rewrite_narinfo_url(&body, &upstream)?;

                log::debug!("Returning response from upstream: {}", upstream);

                return Ok(Response::builder()
                    .status(StatusCode::OK)
                    .header("Content-Type", "text/x-nix-narinfo")
                    .body(Full::new(Bytes::from(rewritten_body)))?);
            }
            Ok(Ok(None)) => {
                // Upstream returned non-success, continue to next
            }
            Ok(Err(e)) => {
                log::warn!("Upstream request failed: {}", e);
            }
            Err(e) => {
                log::warn!("Task join error: {}", e);
            }
        }
    }

    // No successful responses from any upstream
    log::debug!("No upstream returned a successful response");
    Ok(Response::builder()
        .status(StatusCode::NOT_FOUND)
        .body(Full::new(Bytes::from(
            "No upstream returned a successful response",
        )))?)
}
