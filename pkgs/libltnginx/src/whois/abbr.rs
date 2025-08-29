use once_cell::sync::Lazy;
use std::collections::HashMap;

/// A case-insensitive lookup for WHOIS server abbreviations.
///
/// This function provides a mapping from common WHOIS abbreviations (e.g., "afrinic")
/// to their corresponding WHOIS server hostnames (e.g., "whois.afrinic.net").
/// The lookup is case-insensitive.
pub fn lookup_abbr(abbr: &str) -> Option<&'static str> {
    static ABBREVIATIONS: Lazy<HashMap<&'static str, &'static str>> = Lazy::new(|| {
        let mut m = HashMap::new();
        m.insert("afrinic", "whois.afrinic.net");
        m.insert("apnic", "whois.apnic.net");
        m.insert("arin", "whois.arin.net");
        m.insert("lacnic", "whois.lacnic.net");
        m.insert("ripe", "whois.ripe.net");
        m.insert("teredo", "whois.teredo.net");
        m.insert("twnic", "whois.twnic.net");
        m
    });

    ABBREVIATIONS
        .get(&abbr.to_ascii_lowercase().as_str())
        .copied()
}

pub const WHOIS_FALLBACK: &str = "whois.arin.net";

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_lookup_abbr_case_insensitive() {
        assert_eq!(lookup_abbr("afrinic"), Some("whois.afrinic.net"));
        assert_eq!(lookup_abbr("AFRINIC"), Some("whois.afrinic.net"));
        assert_eq!(lookup_abbr("ApNiC"), Some("whois.apnic.net"));
        assert_eq!(lookup_abbr("rIpE"), Some("whois.ripe.net"));
        assert_eq!(lookup_abbr("TEREDO"), Some("whois.teredo.net"));
        assert_eq!(lookup_abbr("TWNIC"), Some("whois.twnic.net"));
    }

    #[test]
    fn test_lookup_abbr_not_found() {
        assert_eq!(lookup_abbr("nonexistent"), None);
        assert_eq!(lookup_abbr("unknown"), None);
    }
}
