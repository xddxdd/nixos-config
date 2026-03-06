use std::fmt;

/// Result of an e164.dn42 SIP caller verification.
#[derive(Debug, PartialEq, Eq)]
pub enum VerifyResult {
    /// Source IP matched a registered SIP server for this number.
    Pass,
    /// Number found in DNS but source IP did not match any server.
    Spoofed,
    /// No NAPTR record found for this number.
    NoEnumRecord,
    /// Could not parse the source IP argument.
    ErrorInvalidIp,
    /// Could not extract digits from the caller ID.
    ErrorInvalidNumber,
}

impl fmt::Display for VerifyResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let s = match self {
            VerifyResult::Pass => "PASS",
            VerifyResult::Spoofed => "SPOOFED",
            VerifyResult::NoEnumRecord => "NO_ENUM_RECORD",
            VerifyResult::ErrorInvalidIp => "ERROR_INVALID_IP",
            VerifyResult::ErrorInvalidNumber => "ERROR_INVALID_NUMBER",
        };
        f.write_str(s)
    }
}
