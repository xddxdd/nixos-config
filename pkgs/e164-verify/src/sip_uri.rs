/// Extract the SIP server hostname from a SIP URI string.
///
/// Given something like "sip:+12345678@sip.example.com;transport=udp"
/// returns "sip.example.com".
pub fn extract_host_from_sip_uri(uri: &str) -> Option<String> {
    // Strip the scheme prefix (sip: / sips:)
    let without_scheme = uri
        .strip_prefix("sip:")
        .or_else(|| uri.strip_prefix("sips:"))?;

    // If there is a user@host part, skip past the @
    let host_part = if let Some(at) = without_scheme.find('@') {
        &without_scheme[at + 1..]
    } else {
        without_scheme
    };

    // Strip parameters (;transport=…) and any trailing path
    let host = host_part.split(';').next()?.split('/').next()?.trim();

    // Strip port if present
    let host = if host.starts_with('[') {
        // Bracketed IPv6: [::1] or [::1]:5060
        let end = host.find(']')?;
        &host[1..end]
    } else if host.contains(':') && !host.contains('.') {
        // Bare IPv6 (colons but no dots)
        host
    } else {
        // IPv4 or hostname — strip trailing :port
        host.split(':').next().unwrap_or(host)
    };

    if host.is_empty() {
        None
    } else {
        Some(host.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simple_sip() {
        assert_eq!(
            extract_host_from_sip_uri("sip:sip.example.com").unwrap(),
            "sip.example.com"
        );
    }

    #[test]
    fn test_with_user() {
        assert_eq!(
            extract_host_from_sip_uri("sip:+1234@sip.example.com").unwrap(),
            "sip.example.com"
        );
    }

    #[test]
    fn test_with_params() {
        assert_eq!(
            extract_host_from_sip_uri("sip:sip.example.com;transport=udp").unwrap(),
            "sip.example.com"
        );
    }

    #[test]
    fn test_with_port() {
        assert_eq!(
            extract_host_from_sip_uri("sip:sip.example.com:5060").unwrap(),
            "sip.example.com"
        );
    }

    #[test]
    fn test_sips_scheme() {
        assert_eq!(
            extract_host_from_sip_uri("sips:secure.example.com").unwrap(),
            "secure.example.com"
        );
    }

    #[test]
    fn test_user_params_port() {
        assert_eq!(
            extract_host_from_sip_uri("sip:+12345678@sip.example.com:5060;transport=tls").unwrap(),
            "sip.example.com"
        );
    }

    #[test]
    fn test_no_scheme_returns_none() {
        assert!(extract_host_from_sip_uri("tel:+12345678").is_none());
    }
}
