//! App state, routing, bounded sharded response cache and the request handler.

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};

use axum::body::{Body, Bytes};
use axum::extract::State;
use axum::http::{header, Method, StatusCode, Uri};
use axum::response::Response;

use crate::assets::Assets;
use crate::corpus::Corpus;
use crate::page::PageRenderer;
use crate::rng::fnv1a64;

const SHARDS: usize = 32;

pub struct Config {
    pub host: String,
    pub port: u16,
    pub socket: Option<PathBuf>,
    pub seed: u64,
    pub doc_root: String,
    pub workers: usize,
    pub cache_size: usize,
    pub asset_dir: String,
    pub data_file: Option<PathBuf>,
}

pub struct App {
    pub corpus: Corpus,
    pub assets: Assets,
    pub config: Config,
    shards: Vec<Mutex<HashMap<String, Bytes>>>,
}

impl App {
    pub fn new(corpus: Corpus, assets: Assets, config: Config) -> App {
        let shards = (0..SHARDS)
            .map(|_| Mutex::new(HashMap::new()))
            .collect::<Vec<_>>();
        App {
            corpus,
            assets,
            config,
            shards,
        }
    }
}

fn empty_response(status: StatusCode) -> Response {
    Response::builder()
        .status(status)
        .body(Body::empty())
        .expect("valid response")
}

fn body_response(status: StatusCode, content_type: &str, body: Bytes, head: bool) -> Response {
    // HEAD must advertise the length the matching GET would return, with no body.
    let payload = if head { Bytes::new() } else { body.clone() };
    Response::builder()
        .status(status)
        .header(header::CONTENT_TYPE, content_type)
        .header(header::CONTENT_LENGTH, body.len())
        .body(Body::from(payload))
        .expect("valid response")
}

fn asset_for<'a>(assets: &'a Assets, segment: &str) -> Option<(String, &'a Bytes)> {
    let (_, ext) = segment.rsplit_once('.')?;
    if ext.is_empty() {
        return None;
    }
    let ext = ext.to_ascii_lowercase();
    assets
        .by_extension(&ext)
        .map(|bytes| (crate::assets::content_type(&ext), bytes))
}

fn shard_index(path: &str) -> usize {
    (fnv1a64(path.as_bytes()) % SHARDS as u64) as usize
}

pub async fn handle(State(app): State<Arc<App>>, method: Method, uri: Uri) -> Response {
    if method != Method::GET && method != Method::HEAD {
        return empty_response(StatusCode::NOT_FOUND);
    }
    let head = method == Method::HEAD;
    let path = uri.path();
    let doc_root = app.config.doc_root.as_str();
    let last_segment = path.rsplit('/').next().unwrap_or("");

    if let Some((content_type, data)) = asset_for(&app.assets, last_segment) {
        return body_response(StatusCode::OK, &content_type, data.clone(), head);
    }

    if last_segment.contains('.') {
        return empty_response(StatusCode::NOT_FOUND);
    }

    let cache_enabled = app.config.cache_size > 0;
    if cache_enabled {
        let shard = &app.shards[shard_index(path)];
        if let Some(bytes) = shard.lock().expect("cache lock").get(path).cloned() {
            return body_response(StatusCode::OK, "text/html; charset=utf-8", bytes, head);
        }
    }

    let mut renderer = PageRenderer::new(&app.corpus, app.config.seed, doc_root, path);
    let html = renderer.render(app.assets.template());
    let bytes = Bytes::from(html.into_bytes());

    if cache_enabled {
        let capacity = (app.config.cache_size / SHARDS).max(1);
        let shard = &app.shards[shard_index(path)];
        let mut map = shard.lock().expect("cache lock");
        if !map.contains_key(path) && map.len() >= capacity {
            map.clear();
        }
        map.insert(path.to_string(), bytes.clone());
    }

    body_response(StatusCode::OK, "text/html; charset=utf-8", bytes, head)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn asset_mapping() {
        let assets = Assets::from_dir(std::path::Path::new("assets")).unwrap();
        assert_eq!(asset_for(&assets, "x.css").map(|v| v.0), Some("text/css".to_string()));
        assert_eq!(
            asset_for(&assets, "x.ico").map(|v| v.0),
            Some("image/x-icon".to_string())
        );
        assert_eq!(
            asset_for(&assets, "x.jpg").map(|v| v.0),
            Some("image/jpeg".to_string())
        );
        assert_eq!(
            asset_for(&assets, "x.JPG").map(|v| v.0),
            Some("image/jpeg".to_string())
        );
        assert_eq!(
            asset_for(&assets, "x.png").map(|v| v.0),
            Some("image/png".to_string())
        );
        assert_eq!(asset_for(&assets, "x.gif"), None);
        assert_eq!(asset_for(&assets, "x."), None);
        assert_eq!(asset_for(&assets, "x"), None);
    }

    #[test]
    fn shard_index_is_bounded() {
        for path in ["/", "/a", "/b/c", "/robots.txt"] {
            assert!(shard_index(path) < SHARDS);
        }
    }
}
