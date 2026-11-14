use super::*;
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::TcpListener,
    task::JoinHandle,
};

async fn backend(replies: Vec<(u16, &'static str)>) -> (Url, JoinHandle<Vec<String>>) {
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let url = base_url(&format!(
        "http://{}/upstream/sakura-llm/",
        listener.local_addr().unwrap()
    ))
    .unwrap();
    let task = tokio::spawn(async move {
        let mut requests = Vec::new();
        for (status, body) in replies {
            let (mut socket, _) = listener.accept().await.unwrap();
            let mut request = Vec::new();
            loop {
                let mut buffer = [0; 4096];
                let size = socket.read(&mut buffer).await.unwrap();
                assert!(size > 0, "connection ended before request body");
                request.extend_from_slice(&buffer[..size]);
                if let Some(end) = request.windows(4).position(|bytes| bytes == b"\r\n\r\n") {
                    let headers = String::from_utf8_lossy(&request[..end]);
                    let length = headers
                        .lines()
                        .find_map(|line| {
                            let (key, value) = line.split_once(':')?;
                            key.eq_ignore_ascii_case("content-length")
                                .then(|| value.trim().parse::<usize>().unwrap())
                        })
                        .unwrap_or(0);
                    if request.len() >= end + 4 + length {
                        break;
                    }
                }
            }
            requests.push(String::from_utf8(request).unwrap());
            socket
                .write_all(
                    format!(
                        "HTTP/1.1 {status} Test\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{body}",
                        body.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
        }
        requests
    });
    (url, task)
}

const MODELS: &str = r#"{"data":[{"id":"sakura-model"}]}"#;
const COMPLETION: &str = r#"{"choices":[{"message":{"content":"Hi"}}]}"#;

#[test]
fn urls_preserve_prefix_and_query() {
    for base in [
        "http://127.0.0.1:8080/upstream/sakura-llm",
        "http://127.0.0.1:8080/upstream/sakura-llm/",
    ] {
        assert_eq!(
            endpoint(&base_url(base).unwrap(), "/v1/models?x=1")
                .unwrap()
                .as_str(),
            "http://127.0.0.1:8080/upstream/sakura-llm/v1/models?x=1"
        );
    }
    assert_eq!(
        endpoint(&base_url("http://localhost:8080").unwrap(), "/health")
            .unwrap()
            .path(),
        "/health"
    );
    let base = base_url("http://localhost:8080/upstream/sakura-llm").unwrap();
    for path in [
        "https://evil.test/",
        "/../../health",
        "/%2e%2e/health",
        "/health#ignored",
    ] {
        assert!(endpoint(&base, path).is_err(), "accepted {path}");
    }
    for url in [
        "ftp://localhost/",
        "http://user:secret@localhost",
        "http://localhost/?a=1",
    ] {
        assert!(base_url(url).is_err());
    }
}

#[tokio::test]
async fn readiness_requires_health_models_and_inference() {
    let (upstream, task) = backend(vec![(200, ""), (200, MODELS), (200, COMPLETION)]).await;
    time::timeout(
        Duration::from_secs(5),
        check_model(&Client::new(), &upstream, Duration::from_secs(5)),
    )
    .await
    .unwrap()
    .unwrap();
    let requests = task.await.unwrap();
    assert!(requests[0].starts_with("GET /upstream/sakura-llm/health "));
    assert!(requests[1].starts_with("GET /upstream/sakura-llm/v1/models "));
    assert!(requests[2].starts_with("POST /upstream/sakura-llm/v1/chat/completions "));
    let body: Value = serde_json::from_str(requests[2].split_once("\r\n\r\n").unwrap().1).unwrap();
    assert_eq!(body["model"], "sakura-model");
    assert_eq!(body["max_tokens"], 1);
    assert_eq!(body["stream"], false);
}

#[tokio::test]
async fn failed_health_or_inference_prevents_websocket() {
    for replies in [
        vec![(503, "loading")],
        vec![(200, ""), (200, MODELS), (500, "inference failed")],
        vec![
            (200, ""),
            (200, MODELS),
            (200, r#"{"error":"not a completion"}"#),
        ],
    ] {
        let (upstream, task) = backend(replies).await;
        let worker = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let args = Args {
            upstream,
            worker_url: base_url(&format!("http://{}", worker.local_addr().unwrap())).unwrap(),
            tg_token: None,
            readiness_timeout: 5,
        };
        tokio::select! {
            result = run(&args) => panic!("client exited: {result:?}"),
            _ = worker.accept() => panic!("connected before model was ready"),
            _ = async {
                time::timeout(Duration::from_secs(5), task).await.unwrap().unwrap();
                time::sleep(Duration::from_millis(50)).await;
            } => {},
        }
    }
}

#[tokio::test]
async fn websocket_preserves_protocol_and_post_body() {
    let (upstream, backend_task) = backend(vec![(418, "backend reply")]).await;
    let worker = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let args = Args {
        upstream,
        worker_url: base_url(&format!("http://{}/pool", worker.local_addr().unwrap())).unwrap(),
        tg_token: Some("a+b&c=?".into()),
        readiness_timeout: 5,
    };
    let worker_task = async {
        let (socket, _) = worker.accept().await.unwrap();
        let mut ws = tokio_tungstenite::accept_hdr_async(
            socket,
            |request: &tokio_tungstenite::tungstenite::handshake::server::Request, response| {
                let uri = Url::parse(&format!("http://worker{}", request.uri())).unwrap();
                assert_eq!(uri.path(), "/pool/ws");
                assert_eq!(
                    uri.query_pairs().collect::<Vec<_>>(),
                    vec![("token".into(), "a+b&c=?".into())]
                );
                Ok(response)
            },
        )
        .await
        .unwrap();
        ws.send(Message::Text(
            json!({
                "id": "job-123", "type": "POST", "path": "/v1/chat/completions?test=1",
                "data": "{\"prompt\":\"日本語\"}"
            })
            .to_string()
            .into(),
        ))
        .await
        .unwrap();
        loop {
            match ws.next().await.unwrap().unwrap() {
                Message::Ping(payload) => ws.send(Message::Pong(payload)).await.unwrap(),
                Message::Text(text) => {
                    assert_eq!(
                        serde_json::from_str::<Value>(&text).unwrap(),
                        json!({
                            "id": "job-123", "status": 418, "data": "backend reply"
                        })
                    );
                    ws.close(None).await.unwrap();
                    break;
                }
                message => panic!("unexpected message: {message:?}"),
            }
        }
    };
    let client = Client::new();
    time::timeout(Duration::from_secs(5), async {
        let (result, ()) = tokio::join!(share(&client, &args), worker_task);
        result.unwrap();
    })
    .await
    .unwrap();
    let requests = backend_task.await.unwrap();
    assert!(requests[0].starts_with("POST /upstream/sakura-llm/v1/chat/completions?test=1 "));
    assert_eq!(
        requests[0].split_once("\r\n\r\n").unwrap().1,
        "{\"prompt\":\"日本語\"}"
    );
}

#[tokio::test]
async fn get_forwards_status_and_connection_failure_is_503() {
    let (upstream, task) = backend(vec![(404, "missing")]).await;
    let reply = forward(
        Client::new(),
        upstream.clone(),
        Request {
            id: json!(42),
            method: "GET".into(),
            path: "/missing".into(),
            data: None,
        },
    )
    .await;
    assert_eq!(reply.id, json!(42));
    assert_eq!(reply.status, 404);
    assert_eq!(reply.data, "missing");
    assert!(task.await.unwrap()[0].starts_with("GET /upstream/sakura-llm/missing "));
    let reply = forward(
        Client::new(),
        upstream,
        Request {
            id: json!(43),
            method: "GET".into(),
            path: "/health".into(),
            data: None,
        },
    )
    .await;
    assert_eq!(reply.status, 503);
    assert!(reply.data.is_empty());
}
