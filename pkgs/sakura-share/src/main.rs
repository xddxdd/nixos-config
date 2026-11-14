use anyhow::{Context, Result, bail, ensure};
use clap::Parser;
use futures_util::{SinkExt, StreamExt};
use reqwest::{Client, Url};
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use std::time::Duration;
use tokio::{task::JoinSet, time};
use tokio_tungstenite::{connect_async, tungstenite::Message};

const RECONNECT_DELAY: Duration = Duration::from_secs(60);
const WS_TIMEOUT: Duration = Duration::from_secs(15);

#[derive(Parser)]
#[command(about = "Share an HTTP model backend with sakura-share")]
struct Args {
    /// Model server base URL, including any llama-swap /upstream/<model> prefix.
    #[arg(long, value_parser = base_url)]
    upstream: Url,
    #[arg(long, default_value = "https://sakura-share.one", value_parser = base_url)]
    worker_url: Url,
    #[arg(long, env = "TG_TOKEN", hide_env_values = true)]
    tg_token: Option<String>,
    /// Allow cold model loading before checking inference, in seconds.
    #[arg(long, default_value_t = 3600, value_parser = clap::value_parser!(u64).range(1..))]
    readiness_timeout: u64,
}

fn base_url(value: &str) -> Result<Url, String> {
    let mut url = Url::parse(value).map_err(|_| "invalid base URL")?;
    if !matches!(url.scheme(), "http" | "https")
        || url.host_str().is_none()
        || !url.username().is_empty()
        || url.password().is_some()
        || url.query().is_some()
        || url.fragment().is_some()
    {
        return Err("base URL must be HTTP(S), without credentials, query, or fragment".into());
    }
    let path = url.path().trim_end_matches('/').to_owned();
    url.set_path(&path);
    Ok(url)
}

fn endpoint(base: &Url, path: &str) -> Result<Url> {
    ensure!(path.starts_with('/'), "request path must start with /");
    // Url::join would discard the llama-swap prefix for absolute request paths.
    let prefix = format!("{}/", base.path().trim_end_matches('/'));
    let url = Url::parse(&format!("{}{path}", base.as_str().trim_end_matches('/')))?;
    ensure!(
        url.origin() == base.origin()
            && url.path().starts_with(&prefix)
            && url.fragment().is_none(),
        "request path escapes upstream prefix"
    );
    Ok(url)
}

async fn check_model(client: &Client, upstream: &Url, timeout: Duration) -> Result<()> {
    let health = client
        .get(endpoint(upstream, "/health")?)
        .timeout(timeout)
        .send()
        .await?;
    ensure!(
        health.status() == reqwest::StatusCode::OK,
        "model health check failed"
    );

    let models: Value = client
        .get(endpoint(upstream, "/v1/models")?)
        .timeout(timeout)
        .send()
        .await?
        .error_for_status()?
        .json()
        .await?;
    let model = models["data"][0]["id"]
        .as_str()
        .filter(|id| !id.is_empty())
        .context("backend returned no model ID")?;
    let reply: Value = client
        .post(endpoint(upstream, "/v1/chat/completions")?)
        .timeout(timeout)
        .json(&json!({
            "model": model,
            "messages": [{"role": "user", "content": "Hello"}],
            "max_tokens": 1,
            "stream": false
        }))
        .send()
        .await?
        .error_for_status()?
        .json()
        .await?;
    ensure!(
        reply["choices"][0]["message"]["content"].is_string(),
        "backend returned no chat completion"
    );
    Ok(())
}

#[derive(Deserialize)]
struct Request {
    id: Value,
    #[serde(rename = "type")]
    method: String,
    path: String,
    data: Option<String>,
}

#[derive(Serialize)]
struct Response {
    id: Value,
    status: u16,
    data: String,
}

async fn forward(client: Client, upstream: Url, request: Request) -> Response {
    let result = async {
        let url = endpoint(&upstream, &request.path).map_err(|_| 500u16)?;
        let builder = match request.method.as_str() {
            "GET" => client.get(url),
            "POST" => client
                .post(url)
                .header("Content-Type", "application/json")
                .body(
                    request
                        .data
                        .context("missing POST body")
                        .map_err(|_| 500u16)?,
                ),
            _ => return Err(500),
        };
        let reply = builder.send().await.map_err(|_| 503u16)?;
        let status = reply.status().as_u16();
        let data = reply.bytes().await.map_err(|_| 503u16)?;
        Ok((status, String::from_utf8_lossy(&data).into_owned()))
    }
    .await;
    let (status, data) = result.unwrap_or_else(|status| (status, String::new()));
    Response {
        id: request.id,
        status,
        data,
    }
}

async fn share(client: &Client, args: &Args) -> Result<()> {
    let mut uri = endpoint(&args.worker_url, "/ws")?;
    let scheme = if uri.scheme() == "https" { "wss" } else { "ws" };
    uri.set_scheme(scheme)
        .map_err(|_| anyhow::anyhow!("invalid websocket scheme"))?;
    if let Some(token) = args.tg_token.as_ref().filter(|token| !token.is_empty()) {
        uri.query_pairs_mut().append_pair("token", token);
    }
    // Handshake errors can contain the token-bearing URI; do not log them.
    let (ws, _) = time::timeout(WS_TIMEOUT, connect_async(uri.as_str()))
        .await
        .context("websocket connection timed out")?
        .map_err(|_| anyhow::anyhow!("websocket connection failed"))?;
    eprintln!("Websocket connected");
    let (mut sink, mut stream) = ws.split();
    let mut tasks = JoinSet::new();
    let mut heartbeat = time::interval(Duration::from_secs(5));
    heartbeat.set_missed_tick_behavior(time::MissedTickBehavior::Delay);
    let mut awaiting_pong = false;

    loop {
        let outgoing = tokio::select! {
            message = stream.next() => match message {
                Some(Ok(Message::Text(text))) => {
                    let request = serde_json::from_str::<Request>(&text)
                        .context("invalid worker request")?;
                    tasks.spawn(forward(client.clone(), args.upstream.clone(), request));
                    continue;
                }
                Some(Ok(Message::Ping(payload))) => Message::Pong(payload),
                Some(Ok(Message::Pong(_))) => {
                    awaiting_pong = false;
                    continue;
                }
                Some(Ok(Message::Close(frame))) => {
                    let _ = time::timeout(WS_TIMEOUT, sink.send(Message::Close(frame))).await;
                    return Ok(());
                }
                None => return Ok(()),
                Some(Err(_)) => bail!("websocket read failed"),
                _ => continue,
            },
            response = tasks.join_next(), if !tasks.is_empty() => {
                Message::Text(serde_json::to_string(&response.context("missing task")??)?.into())
            }
            _ = heartbeat.tick() => {
                ensure!(!awaiting_pong, "websocket heartbeat timed out");
                awaiting_pong = true;
                Message::Ping(Vec::new().into())
            }
        };
        time::timeout(WS_TIMEOUT, sink.send(outgoing))
            .await
            .context("websocket write timed out")?
            .map_err(|_| anyhow::anyhow!("websocket write failed"))?;
    }
}

async fn run(args: &Args) -> Result<()> {
    let client = Client::builder()
        .no_proxy()
        .connect_timeout(Duration::from_secs(15))
        .timeout(Duration::from_secs(300))
        .build()?;
    let readiness_timeout = Duration::from_secs(args.readiness_timeout);
    loop {
        eprintln!("Checking model health and inference before connecting");
        match time::timeout(
            readiness_timeout,
            check_model(&client, &args.upstream, readiness_timeout),
        )
        .await
        {
            Ok(Ok(())) => {
                if let Err(error) = share(&client, args).await {
                    eprintln!("Sharing stopped: {error:#}");
                }
            }
            Ok(Err(error)) => eprintln!("Model is not ready: {error:#}"),
            Err(_) => eprintln!("Model readiness check timed out"),
        }
        eprintln!("Waiting 60 seconds before retrying");
        time::sleep(RECONNECT_DELAY).await;
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();
    let mut terminate = tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())?;
    tokio::select! {
        result = run(&args) => result?,
        result = tokio::signal::ctrl_c() => result?,
        _ = terminate.recv() => {},
    }
    // Dropping run also drops its JoinSet, cancelling all in-flight requests.
    eprintln!("Stopped sharing");
    Ok(())
}

#[cfg(test)]
mod tests;
