use anyhow::Result;
use url::Url;

/// Parse a .narinfo response and rewrite relative URLs to absolute URLs
pub fn rewrite_narinfo_url(body: &str, upstream_base: &Url) -> Result<String> {
    let mut rewritten = String::with_capacity(body.len());

    for line in body.lines() {
        if let Some(url_value) = line.strip_prefix("URL: ") {
            // Check if the URL is relative or absolute
            if let Ok(_parsed) = Url::parse(url_value) {
                // It's an absolute URL, keep it as is
                rewritten.push_str(line);
            } else {
                // It's a relative URL, make it absolute
                let absolute_url = upstream_base.join(url_value)?;
                rewritten.push_str(&format!("URL: {}", absolute_url));
            }
        } else {
            rewritten.push_str(line);
        }
        rewritten.push('\n');
    }

    Ok(rewritten)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rewrite_relative_url() {
        let body = "StorePath: /nix/store/test\nURL: nar/test.nar.xz\nFileSize: 123\n";
        let base = Url::parse("https://cache.nixos.org").unwrap();
        let result = rewrite_narinfo_url(body, &base).unwrap();
        assert!(result.contains("URL: https://cache.nixos.org/nar/test.nar.xz"));
    }

    #[test]
    fn test_preserve_absolute_url() {
        let body =
            "StorePath: /nix/store/test\nURL: https://example.com/nar/test.nar.xz\nFileSize: 123\n";
        let base = Url::parse("https://cache.nixos.org").unwrap();
        let result = rewrite_narinfo_url(body, &base).unwrap();
        assert!(result.contains("URL: https://example.com/nar/test.nar.xz"));
    }

    #[test]
    fn test_rewrite_absolute_path_url() {
        // URLs starting with "/" are absolute paths under the current hostname
        let body = "StorePath: /nix/store/test\nURL: /nar/test.nar.xz\nFileSize: 123\n";
        let base = Url::parse("https://cache.nixos.org").unwrap();
        let result = rewrite_narinfo_url(body, &base).unwrap();
        assert!(result.contains("URL: https://cache.nixos.org/nar/test.nar.xz"));
    }

    #[test]
    fn test_rewrite_absolute_path_url_with_subpath_upstream() {
        // URLs starting with "/" should resolve to origin, not append to subpath
        // /nar/test.nar.xz with base https://attic.xuyh0120.win/lantian
        // should become https://attic.xuyh0120.win/nar/test.nar.xz (NOT /lantian/nar/...)
        let body = "StorePath: /nix/store/test\nURL: /nar/test.nar.xz\nFileSize: 123\n";
        let base = Url::parse("https://attic.xuyh0120.win/lantian").unwrap();
        let result = rewrite_narinfo_url(body, &base).unwrap();
        assert!(result.contains("URL: https://attic.xuyh0120.win/nar/test.nar.xz"));
    }
}
