use anyhow::Result;
use http_body_util::Full;
use hyper::body::Bytes;
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{Request, Response};
use hyper_util::rt::TokioIo;

use crate::proxy::AppState;

/// Serves incoming connections from a listener
pub async fn serve_connections<S>(
    mut listener: impl Listener<Stream = S>,
    state: AppState,
) -> Result<()>
where
    S: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin + Send + 'static,
{
    loop {
        let (stream, _) = listener.accept().await?;
        let io = TokioIo::new(stream);
        let state = state.clone();

        tokio::task::spawn(async move {
            if let Err(err) = http1::Builder::new()
                .serve_connection(
                    io,
                    service_fn(move |req| handle_request(state.clone(), req)),
                )
                .await
            {
                log::error!("Error serving connection: {:?}", err);
            }
        });
    }
}

/// Trait to abstract over different listener types
pub trait Listener {
    type Stream;
    async fn accept(&mut self) -> Result<(Self::Stream, std::net::SocketAddr)>;
}

impl Listener for tokio::net::TcpListener {
    type Stream = tokio::net::TcpStream;
    async fn accept(&mut self) -> Result<(Self::Stream, std::net::SocketAddr)> {
        Ok(tokio::net::TcpListener::accept(self).await?)
    }
}

impl Listener for tokio::net::UnixListener {
    type Stream = tokio::net::UnixStream;
    async fn accept(&mut self) -> Result<(Self::Stream, std::net::SocketAddr)> {
        let (stream, _addr) = tokio::net::UnixListener::accept(self).await?;
        // Unix sockets don't have a SocketAddr, so we use a dummy one
        let dummy_addr = "0.0.0.0:0".parse().unwrap();
        Ok((stream, dummy_addr))
    }
}

async fn handle_request(
    state: AppState,
    req: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>> {
    let method = req.method().clone();
    let uri = req.uri().clone();
    let path = uri.path().trim_start_matches('/').to_string();

    // Log incoming request
    log::debug!("{} {}", method, uri);

    // Start timing the request
    let start = std::time::Instant::now();

    // Process the request
    let response = crate::proxy::proxy_handler(state, path).await;

    // Calculate elapsed time
    let elapsed = start.elapsed();

    // Log response with status code and timing
    log::info!(
        "{} {} - {} ({:.3}ms)",
        method,
        uri,
        response.status().as_u16(),
        elapsed.as_secs_f64() * 1000.0
    );

    Ok(response)
}
