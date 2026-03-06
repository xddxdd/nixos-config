use anyhow::{anyhow, Result};
use regex::Regex;

/// Extract the phone number digits from a SIP caller ID string.
///
/// Accepted formats:
///   12345678
///   12345678@example.com
///   Display Name <12345678@example.com>
pub fn parse_caller_id(caller_id: &str) -> Result<String> {
    let re = Regex::new(
        r"(?x)
        (?:
            # Format: Display Name <sip-uri>  or  <sip-uri>
            (?:[^<]*)               # optional display name
            <\+?([0-9]+)            # opening angle bracket + digits
            (?:@[^>]*)?>            # optional @domain then closing bracket
        ) |
        (?:
            # Format: digits@domain  or  bare digits
            \+?([0-9]+)
            (?:@.*)?$
        )
        ",
    )
    .unwrap();

    let caps = re
        .captures(caller_id.trim())
        .ok_or_else(|| anyhow!("Cannot parse caller ID: {:?}", caller_id))?;

    let digits = caps
        .get(1)
        .or_else(|| caps.get(2))
        .ok_or_else(|| anyhow!("No phone number found in caller ID: {:?}", caller_id))?
        .as_str()
        .to_string();

    if digits.is_empty() {
        return Err(anyhow!(
            "Empty phone number extracted from caller ID: {:?}",
            caller_id
        ));
    }

    Ok(digits)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_bare_digits() {
        assert_eq!(parse_caller_id("12345678").unwrap(), "12345678");
    }

    #[test]
    fn test_with_plus() {
        assert_eq!(parse_caller_id("+12345678").unwrap(), "12345678");
    }

    #[test]
    fn test_user_at_host() {
        assert_eq!(parse_caller_id("12345678@example.com").unwrap(), "12345678");
    }

    #[test]
    fn test_sip_uri_with_plus() {
        assert_eq!(
            parse_caller_id("+12345678@example.com").unwrap(),
            "12345678"
        );
    }

    #[test]
    fn test_display_name() {
        assert_eq!(
            parse_caller_id("Caller <12345678@example.com>").unwrap(),
            "12345678"
        );
    }

    #[test]
    fn test_display_name_with_plus() {
        assert_eq!(
            parse_caller_id("John Doe <+12345678@sip.example.com>").unwrap(),
            "12345678"
        );
    }

    #[test]
    fn test_angle_bracket_no_display() {
        assert_eq!(
            parse_caller_id("<12345678@sip.example.com>").unwrap(),
            "12345678"
        );
    }

    #[test]
    fn test_invalid() {
        assert!(parse_caller_id("no-digits-here").is_err());
    }
}
