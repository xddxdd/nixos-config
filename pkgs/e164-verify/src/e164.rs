/// Build the e164.dn42 NAPTR query domain for the given digit string.
///
/// E.g. "12345678" → "8.7.6.5.4.3.2.1.e164.dn42."
pub fn build_e164_domain(digits: &str) -> String {
    let reversed: String = digits
        .chars()
        .rev()
        .map(|c| c.to_string())
        .collect::<Vec<_>>()
        .join(".");
    format!("{}.e164.dn42.", reversed)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_standard_number() {
        assert_eq!(build_e164_domain("12345678"), "8.7.6.5.4.3.2.1.e164.dn42.");
    }

    #[test]
    fn test_single_digit() {
        assert_eq!(build_e164_domain("1"), "1.e164.dn42.");
    }

    #[test]
    fn test_long_e164() {
        // E.164 numbers can be up to 15 digits
        assert_eq!(
            build_e164_domain("441234567890"),
            "0.9.8.7.6.5.4.3.2.1.4.4.e164.dn42."
        );
    }
}
