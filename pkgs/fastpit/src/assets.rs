//! Static assets: loaded at startup from a directory keyed by file extension.
//!
//! A single `html` file becomes the page template; every other regular file is
//! served for a request whose last path segment ends in that file's lowercase
//! extension. Nothing is embedded in the binary. Assets are matched purely by
//! extension name; the response content type is guessed from that name.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use axum::body::Bytes;

/// Guess a content type from an extension name, falling back to
/// `application/octet-stream` for anything unknown.
pub fn content_type(ext: &str) -> String {
    mime_guess::from_ext(ext)
        .first_or_octet_stream()
        .to_string()
}

#[derive(Debug)]
pub struct Assets {
    template: String,
    by_extension: HashMap<String, Bytes>,
}

impl Assets {
    pub fn from_dir(dir: &Path) -> Result<Assets, String> {
        let entries = std::fs::read_dir(dir).map_err(|e| format!("{}: {}", dir.display(), e))?;
        let mut files: Vec<(String, PathBuf)> = Vec::new();
        for entry in entries {
            let entry = entry.map_err(|e| format!("{}: {}", dir.display(), e))?;
            let path = entry.path();
            let file_type = entry
                .file_type()
                .map_err(|e| format!("{}: {}", path.display(), e))?;
            if !file_type.is_file() {
                continue;
            }
            files.push((entry.file_name().to_string_lossy().into_owned(), path));
        }
        // Sorted so duplicate/extension errors and the chosen html file are
        // deterministic regardless of directory iteration order.
        files.sort_by(|a, b| a.0.cmp(&b.0));

        let mut seen: HashMap<String, PathBuf> = HashMap::new();
        let mut template: Option<String> = None;
        let mut by_extension: HashMap<String, Bytes> = HashMap::new();

        for (name, path) in files {
            let ext = match name.rsplit_once('.') {
                Some((_, ext)) => ext.to_ascii_lowercase(),
                None => return Err(format!("{}: file has no extension", path.display())),
            };
            if let Some(previous) = seen.get(&ext) {
                return Err(format!(
                    "duplicate extension {:?}: {} and {}",
                    ext,
                    previous.display(),
                    path.display()
                ));
            }
            seen.insert(ext.clone(), path.clone());

            if ext == "html" {
                let raw =
                    std::fs::read(&path).map_err(|e| format!("{}: {}", path.display(), e))?;
                let text = String::from_utf8(raw)
                    .map_err(|_| format!("{}: not valid UTF-8", path.display()))?;
                template = Some(text);
                continue;
            }

            let bytes =
                std::fs::read(&path).map_err(|e| format!("{}: {}", path.display(), e))?;
            by_extension.insert(ext, Bytes::from(bytes));
        }

        let template = match template {
            Some(template) => template,
            None => return Err(format!("{}: no .html file in asset directory", dir.display())),
        };

        Ok(Assets {
            template,
            by_extension,
        })
    }

    pub fn template(&self) -> &str {
        &self.template
    }

    pub fn by_extension(&self, ext: &str) -> Option<&Bytes> {
        self.by_extension.get(ext)
    }

    pub fn extensions(&self) -> impl Iterator<Item = &str> {
        let mut extensions: Vec<&str> = self.by_extension.keys().map(String::as_str).collect();
        extensions.sort_unstable();
        extensions.into_iter()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicU64, Ordering};

    fn temp_dir(tag: &str) -> PathBuf {
        static COUNTER: AtomicU64 = AtomicU64::new(0);
        let n = COUNTER.fetch_add(1, Ordering::Relaxed);
        let dir = std::env::temp_dir().join(format!(
            "fastpit-assets-{}-{}-{}",
            std::process::id(),
            tag,
            n
        ));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).unwrap();
        dir
    }

    fn write(dir: &Path, name: &str, contents: &[u8]) {
        std::fs::write(dir.join(name), contents).unwrap();
    }

    #[test]
    fn loads_project_assets() {
        let assets = Assets::from_dir(Path::new("assets")).unwrap();
        assert!(!assets.template().is_empty());
        assert!(assets.template().contains("{MAIN}"));

        let expected = [
            ("css", "text/css"),
            ("ico", "image/x-icon"),
            ("jpg", "image/jpeg"),
            ("png", "image/png"),
            ("txt", "text/plain"),
        ];
        for (ext, expected_type) in expected {
            let bytes = assets
                .by_extension(ext)
                .unwrap_or_else(|| panic!("missing .{}", ext));
            assert_eq!(content_type(ext), expected_type);
            assert!(!bytes.is_empty());
        }

        let extensions: Vec<&str> = assets.extensions().collect();
        let mut sorted = extensions.clone();
        sorted.sort_unstable();
        assert_eq!(extensions, sorted);
        assert_eq!(extensions, vec!["css", "ico", "jpg", "png", "txt"]);
    }

    #[test]
    fn rejects_duplicate_extensions() {
        let dir = temp_dir("dup");
        write(&dir, "index.html", b"{MAIN}");
        write(&dir, "a.css", b"a");
        write(&dir, "b.css", b"b");
        let err = Assets::from_dir(&dir).unwrap_err();
        assert!(err.contains("a.css"), "{}", err);
        assert!(err.contains("b.css"), "{}", err);
        assert!(err.contains("duplicate"), "{}", err);
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn rejects_missing_html() {
        let dir = temp_dir("nohtml");
        write(&dir, "a.css", b"a");
        let err = Assets::from_dir(&dir).unwrap_err();
        assert!(err.contains("html"), "{}", err);
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn accepts_unknown_extension() {
        let dir = temp_dir("unknown");
        write(&dir, "index.html", b"{MAIN}");
        write(&dir, "blob.foo", b"x");
        let assets = Assets::from_dir(&dir).unwrap();
        assert!(assets.by_extension("foo").is_some());
        assert_eq!(content_type("foo"), "application/octet-stream");
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn rejects_file_without_extension() {
        let dir = temp_dir("noext");
        write(&dir, "index.html", b"{MAIN}");
        write(&dir, "README", b"x");
        let err = Assets::from_dir(&dir).unwrap_err();
        assert!(err.contains("README"), "{}", err);
        std::fs::remove_dir_all(&dir).unwrap();
    }

    #[test]
    fn routing_serves_known_extensions_and_404s_missing() {
        use crate::app::{handle, App, Config};
        use crate::corpus::Corpus;
        use axum::extract::State;
        use axum::http::{header, Method, Uri};

        let assets = Assets::from_dir(Path::new("assets")).unwrap();
        let config = Config {
            host: "127.0.0.1".to_string(),
            port: 0,
            socket: None,
            seed: 0,
            doc_root: String::new(),
            workers: 1,
            cache_size: 64,
            asset_dir: "assets".to_string(),
            data_file: None,
        };
        let app = std::sync::Arc::new(App::new(Corpus::embedded(), assets, config));
        let runtime = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();

        let request = |path: &str| {
            let app = app.clone();
            let uri: Uri = path.parse().unwrap();
            runtime.block_on(async move {
                let response = handle(State(app), Method::GET, uri).await;
                let status = response.status().as_u16();
                let content_type = response
                    .headers()
                    .get(header::CONTENT_TYPE)
                    .and_then(|value| value.to_str().ok())
                    .map(|value| value.to_string());
                (status, content_type)
            })
        };

        assert_eq!(request("/x.css"), (200, Some("text/css".to_string())));
        assert_eq!(request("/robots.txt"), (200, Some("text/plain".to_string())));
        assert_eq!(request("/y.png"), (200, Some("image/png".to_string())));
        assert_eq!(request("/q.gif"), (404, None));
    }
}
