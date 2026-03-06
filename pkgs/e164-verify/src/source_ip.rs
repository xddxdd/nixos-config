use std::net::IpAddr;
use std::str::FromStr;

use anyhow::{anyhow, Context, Result};

/// Strip an optional port from a source-IP string and return the parsed IpAddr.
///
/// Handles:
///   1.2.3.4
///   1.2.3.4:5060
///   ::1
///   [::1]
///   [::1]:5060
pub fn parse_source_ip(source_ip: &str) -> Result<IpAddr> {
    let s = source_ip.trim();

    // Bracketed IPv6 (with or without port): [::1]  or  [::1]:5060
    if s.starts_with('[') {
        let end = s
            .find(']')
            .ok_or_else(|| anyhow!("Unmatched '[' in source IP: {:?}", s))?;
        let ip_str = &s[1..end];
        return IpAddr::from_str(ip_str)
            .with_context(|| format!("Invalid IPv6 address: {:?}", ip_str));
    }

    // If there's exactly one colon it is IPv4:port; strip the port.
    if s.chars().filter(|&c| c == ':').count() == 1 {
        if let Some(colon) = s.rfind(':') {
            let ip_str = &s[..colon];
            return IpAddr::from_str(ip_str)
                .with_context(|| format!("Invalid IPv4 address: {:?}", ip_str));
        }
    }

    // Bare IPv4 or bare IPv6 (multiple colons, no brackets)
    IpAddr::from_str(s).with_context(|| format!("Invalid IP address: {:?}", s))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_bare_v4() {
        assert_eq!(
            parse_source_ip("1.2.3.4").unwrap(),
            IpAddr::from_str("1.2.3.4").unwrap()
        );
    }

    #[test]
    fn test_v4_with_port() {
        assert_eq!(
            parse_source_ip("1.2.3.4:5060").unwrap(),
            IpAddr::from_str("1.2.3.4").unwrap()
        );
    }

    #[test]
    fn test_bare_v6() {
        assert_eq!(
            parse_source_ip("::1").unwrap(),
            IpAddr::from_str("::1").unwrap()
        );
    }

    #[test]
    fn test_bracketed_v6() {
        assert_eq!(
            parse_source_ip("[::1]").unwrap(),
            IpAddr::from_str("::1").unwrap()
        );
    }

    #[test]
    fn test_bracketed_v6_with_port() {
        assert_eq!(
            parse_source_ip("[::1]:5060").unwrap(),
            IpAddr::from_str("::1").unwrap()
        );
    }

    #[test]
    fn test_invalid() {
        assert!(parse_source_ip("not-an-ip").is_err());
    }

    #[test]
    fn test_unmatched_bracket() {
        assert!(parse_source_ip("[::1").is_err());
    }
}
