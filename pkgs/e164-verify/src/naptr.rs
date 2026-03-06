use c_ares::NAPTRResult;
use c_ares_resolver::BlockingResolver;

use crate::sip_uri::extract_host_from_sip_uri;

/// Pull a SIP URI from a c-ares NAPTRResult's service/regexp/replacement fields.
///
/// We handle two styles:
///   1. Regexp style: `!^.*$!sip:host!` — the replacement embedded in regexp
///   2. Replacement field: a direct SIP URI in NAPTR replacement_pattern
pub fn sip_uri_from_naptr(naptr: &NAPTRResult<'_>) -> Option<String> {
    let service = naptr.service_name().to_ascii_lowercase();
    // Only care about E2U+sip (and its sip+E2U variant)
    if !service.contains("sip") {
        return None;
    }

    sip_uri_from_fields(naptr.reg_exp(), naptr.replacement_pattern())
}

/// Core parsing logic — operates on plain `&str` so it can be unit-tested
/// without constructing a real DNS response object.
fn sip_uri_from_fields(regexp: &str, replacement_pattern: &str) -> Option<String> {
    // Try regexp field first: extract the replacement from !<regex>!<replace>!
    if !regexp.is_empty() {
        let mut chars = regexp.chars();
        if let Some(delim) = chars.next() {
            let rest: String = chars.collect();
            let parts: Vec<&str> = rest.split(delim).collect();
            // parts[0] = regex pattern, parts[1] = replacement
            if parts.len() >= 2 {
                let replacement = parts[1];
                if replacement.starts_with("sip:") || replacement.starts_with("sips:") {
                    return Some(replacement.to_string());
                }
            }
        }
    }

    // Fall back to replacement field
    if replacement_pattern.starts_with("sip:") || replacement_pattern.starts_with("sips:") {
        return Some(replacement_pattern.to_string());
    }

    None
}

/// Extract SIP server hosts from NAPTR records for `domain`.
/// Returns a list of hostnames to resolve, or None if none found.
pub fn naptr_sip_hosts(resolver: &BlockingResolver, domain: &str) -> Option<Vec<String>> {
    let results = resolver.query_naptr(domain).ok()?;
    let mut hosts = Vec::new();

    for naptr in &results {
        if let Some(uri) = sip_uri_from_naptr(&naptr) {
            eprintln!("Found SIP URI: {}", uri);
            if let Some(host) = extract_host_from_sip_uri(&uri) {
                eprintln!("  → SIP host: {}", host);
                hosts.push(host);
            }
        }
    }

    if hosts.is_empty() {
        None
    } else {
        Some(hosts)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Helper: call sip_uri_from_fields directly (simulates a SIP-service NAPTR
    /// record passing the service filter, with the given regexp and replacement).
    fn check(regexp: &str, replacement: &str) -> Option<String> {
        sip_uri_from_fields(regexp, replacement)
    }

    #[test]
    fn test_regexp_style_e2u_sip() {
        assert_eq!(
            check("!^.*$!sip:sip.example.com!", "").unwrap(),
            "sip:sip.example.com"
        );
    }

    #[test]
    fn test_regexp_style_sip_e2u() {
        assert_eq!(
            check("!^.*$!sip:other.example.com!", "").unwrap(),
            "sip:other.example.com"
        );
    }

    #[test]
    fn test_non_sip_service_ignored() {
        // Non-SIP regexp replacement → None
        assert!(check("!^.*$!mailto:user@example.com!", "").is_none());
    }

    #[test]
    fn test_empty_regexp_no_replacement() {
        // No regexp and replacement is not a SIP URI → None
        assert!(check("", ".").is_none());
    }

    #[test]
    fn test_regexp_backref_backslash1() {
        // Real-world pattern from pbx.gensokyo.dn42:
        //   "!^(.*)$!sip:\\1@pbx.gensokyo.dn42:5060!"
        // The \\1 in DNS zone text becomes the two bytes '\' + '1' on the wire.
        // We don't apply the backreference; we only extract the host from the
        // URI template, which is enough to resolve the SIP server.
        let uri = check("!^(.*)$!sip:\\1@pbx.gensokyo.dn42:5060!", ".").unwrap();
        let host = crate::sip_uri::extract_host_from_sip_uri(&uri).unwrap();
        assert_eq!(host, "pbx.gensokyo.dn42");
    }

    #[test]
    fn test_regexp_backref_lantian_dn42() {
        // Real-world pattern from v-ps-sea.lantian.dn42:
        //   "!^(.*)$!sip:\\1@v-ps-sea.lantian.dn42:5060!"
        // dig displays this as \001 but the wire format is the two-byte sequence
        // backslash + '1', identical to the gensokyo.dn42 pattern above.
        let uri = check("!^(.*)$!sip:\\1@v-ps-sea.lantian.dn42:5060!", ".").unwrap();
        let host = crate::sip_uri::extract_host_from_sip_uri(&uri).unwrap();
        assert_eq!(host, "v-ps-sea.lantian.dn42");
    }
}
