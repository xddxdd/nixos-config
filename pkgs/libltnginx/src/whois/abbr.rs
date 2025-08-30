/// A case-insensitive lookup for WHOIS server abbreviations.
///
/// This function provides a mapping from common WHOIS abbreviations (e.g., "afrinic")
/// to their corresponding WHOIS server hostnames (e.g., "whois.afrinic.net").
/// The lookup is case-insensitive.
pub fn lookup_abbr(abbr: &str) -> Option<&'static str> {
    match abbr.to_ascii_lowercase().as_str() {
        "afrinic" => Some("whois.afrinic.net"),
        "apnic" => Some("whois.apnic.net"),
        "arin" => Some("whois.arin.net"),
        "lacnic" => Some("whois.lacnic.net"),
        "ripe" => Some("whois.ripe.net"),
        "teredo" => Some("whois.teredo.net"),
        "twnic" => Some("whois.twnic.net"),
        _ => None,
    }
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
