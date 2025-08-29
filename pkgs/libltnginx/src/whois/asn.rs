use crate::whois::abbr::{WHOIS_FALLBACK, lookup_abbr};
use once_cell::sync::Lazy;
use std::ffi::CString;
use std::os::raw::c_char; // Required for FFI functions.

// Define a struct to hold the AS range and server name
struct AsRange {
    start: u32,
    end: u32,
    server: String,
}

// Helper function to parse ASN which might be in "asplain" (X.Y) format or decimal.
fn normalize_asn(asn_str: &str) -> Option<u32> {
    if asn_str.contains('.') {
        let parts: Vec<&str> = asn_str.split('.').collect();
        if parts.len() == 2 {
            let h_part = parts[0].parse::<u32>().ok()?;
            let l_part = parts[1].parse::<u32>().ok()?;
            // As-dot notation (X.Y) means X * 65536 + Y
            Some(h_part * 65536 + l_part)
        } else {
            None
        }
    } else {
        asn_str.parse::<u32>().ok()
    }
}

// Embed the content of resources/as_del_list
const AS_DEL_LIST_CONTENT: &str = include_str!("../../resources/as_del_list");

// Static variable to store parsed AS ranges, initialized once.
static AS_RANGES: Lazy<Vec<AsRange>> = Lazy::new(|| {
    let mut ranges = Vec::new();
    for line in AS_DEL_LIST_CONTENT.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }

        let parts: Vec<&str> = line.split('\t').collect();
        if parts.len() == 3 {
            if let (Some(start_asn), Some(end_asn)) =
                (normalize_asn(parts[0]), normalize_asn(parts[1]))
            {
                ranges.push(AsRange {
                    start: start_asn,
                    end: end_asn,
                    server: parts[2].to_string(),
                });
            }
        }
    }
    // Do not sort to preserve the order of rules in the file.
    // The specific rules appear earlier, and the broad "catch-all" ARIN is later.
    ranges
});

#[unsafe(no_mangle)]
pub extern "C" fn whois_asn_lookup(asn: u32) -> *mut c_char {
    let mut matching_server: Option<&str> = None;
    for range in AS_RANGES.iter() {
        if asn >= range.start && asn <= range.end {
            matching_server = Some(&range.server);
            break;
        }
    }

    let final_server = matching_server.unwrap_or(WHOIS_FALLBACK);
    let mapped_server = lookup_abbr(final_server).unwrap_or(final_server);
    CString::new(mapped_server)
        .expect("CString::new failed")
        .into_raw()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::free_string;
    use std::ffi::CStr;

    #[test]
    fn test_whois_asn_lookup_ripe() {
        let asn = 250; // Within 248-251 ripe
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.ripe.net");

        let asn_dot = 1150; // Within 1101-1200 ripe
        let c_str_ptr_dot = whois_asn_lookup(asn_dot);
        let result_dot = unsafe { CStr::from_ptr(c_str_ptr_dot).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr_dot);
        }
        assert_eq!(result_dot, "whois.ripe.net");
    }

    #[test]
    fn test_whois_asn_lookup_mil() {
        let asn = 310; // Within 306-371 whois.nic.mil
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.nic.mil");
    }

    #[test]
    fn test_whois_asn_lookup_jp() {
        let asn = 2500; // Within 2497-2528 whois.nic.ad.jp
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.nic.ad.jp");
    }

    #[test]
    fn test_whois_asn_lookup_arin_catch_all() {
        let asn = 100; // Outside specific ranges, should fall into arin (1-64296 arin)
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.arin.net");

        let asn_high = 64000; // Within catch-all arin but also apnic, apnic takes precedence
        let c_str_ptr_high = whois_asn_lookup(asn_high);
        let result_high = unsafe {
            CStr::from_ptr(c_str_ptr_high)
                .to_string_lossy()
                .into_owned()
        };
        unsafe {
            free_string(c_str_ptr_high);
        }
        assert_eq!(result_high, "whois.apnic.net");
    }

    #[test]
    fn test_whois_asn_lookup_dot_decimal_apnic() {
        // Corresponds to 2.0 - 2.65535 apnic, which means 2*65536 + 0 to 2*65536 + 65535
        let asn = (2 * 65536) + 100; // An ASN within the 2.X range
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.apnic.net");
    }

    #[test]
    fn test_whois_asn_lookup_dot_decimal_afrinic() {
        // Corresponds to 5.0 - 5.65535 afrinic
        let asn = (5 * 65536) + 500;
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.afrinic.net");
    }

    #[test]
    fn test_whois_asn_lookup_private_asn_block_ripe() {
        // Corresponds to 4200000000 - 4294967294 ripe
        let asn = 4200000000 + 1000;
        let c_str_ptr = whois_asn_lookup(asn);
        let result = unsafe { CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned() };
        unsafe {
            free_string(c_str_ptr);
        }
        assert_eq!(result, "whois.ripe.net");
    }
}
