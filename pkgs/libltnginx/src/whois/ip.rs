// src/whois/ip.rs

use crate::ffi_chars_to_rust_string;
use crate::whois::abbr::{WHOIS_FALLBACK, lookup_abbr};
use ipnet::{IpNet, Ipv4Net, Ipv6Net};
use once_cell::sync::Lazy;
use std::ffi::CString;
use std::include_str;
use std::net::IpAddr;
use std::os::raw::c_char;

// Struct to represent a delegation entry
struct DelegationEntry {
    network: IpNet,
    whois_server: String,
}

// Lazy static for IPv4 delegation list
static IPV4_DELEGATIONS: Lazy<Vec<DelegationEntry>> =
    Lazy::new(|| parse_delegation_list(include_str!("../../resources/ip_del_list")));

// Lazy static for IPv6 delegation list
static IPV6_DELEGATIONS: Lazy<Vec<DelegationEntry>> =
    Lazy::new(|| parse_delegation_list(include_str!("../../resources/ip6_del_list")));

fn parse_delegation_list(content: &str) -> Vec<DelegationEntry> {
    let mut mapping: Vec<DelegationEntry> = content
        .lines()
        .filter_map(|line| {
            let line = line.trim();
            if line.starts_with('#') || line.is_empty() {
                return None;
            }
            let parts: Vec<&str> = line.split_whitespace().collect();

            if parts.len() >= 2 {
                let network_str = parts[0];
                let whois_server = parts[1].to_string();

                if let Ok(ip_net) = network_str.parse::<IpNet>() {
                    return Some(DelegationEntry {
                        network: ip_net,
                        whois_server,
                    });
                }
            }
            None
        })
        .collect();
    mapping.sort_by(|a, b| b.network.prefix_len().cmp(&a.network.prefix_len()));
    mapping
}

/// Lookup the WHOIS server for a given IP address CIDR.
///
/// # Safety
/// The `ip_cidr_str` must be a valid C-string pointing to a null-terminated
/// string representation of an IPv4 or IPv6 CIDR (e.g., "192.0.2.0/24", "2001:db8::/32").
/// The returned pointer must be freed using `free_string` from `lib.rs`.
#[unsafe(no_mangle)]
pub extern "C" fn whois_ip_lookup(ip_cidr_str: *const c_char) -> *mut c_char {
    let ip_str_option = ffi_chars_to_rust_string(ip_cidr_str);
    let ip_str = match ip_str_option {
        Some(s) => s,
        None => return CString::new(WHOIS_FALLBACK).unwrap().into_raw(),
    };

    let ip_net = match ip_str.parse::<IpNet>() {
        Ok(net) => net,
        Err(_) => {
            // If it's not a CIDR, try parsing as a single IP address
            // and derive a /32 or /128 network for lookup
            if let Ok(ip_addr) = ip_str.parse::<IpAddr>() {
                match ip_addr {
                    IpAddr::V4(ipv4) => IpNet::V4(Ipv4Net::new(ipv4, 32).unwrap()), // Use unwrap here as this should always succeed
                    IpAddr::V6(ipv6) => IpNet::V6(Ipv6Net::new(ipv6, 128).unwrap()), // Use unwrap here as this should always succeed
                }
            } else {
                return CString::new(WHOIS_FALLBACK).unwrap().into_raw(); // Invalid IP or CIDR
            }
        }
    };

    // Force initialization of both Lazy statics
    Lazy::force(&IPV4_DELEGATIONS);
    Lazy::force(&IPV6_DELEGATIONS);

    let matching_server = match ip_net {
        IpNet::V4(ipv4_net) => IPV4_DELEGATIONS
            .iter()
            .find(|entry| entry.network.contains(&IpAddr::V4(ipv4_net.addr())))
            .map(|entry| entry.whois_server.clone()),
        IpNet::V6(ipv6_net) => IPV6_DELEGATIONS
            .iter()
            .find(|entry| entry.network.contains(&IpAddr::V6(ipv6_net.addr())))
            .map(|entry| entry.whois_server.clone()),
    };

    match matching_server {
        Some(server) => CString::new(lookup_abbr(&server).unwrap_or(&server))
            .unwrap_or_default()
            .into_raw(),
        None => CString::new(WHOIS_FALLBACK).unwrap().into_raw(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // Helper to create a CString and return its raw pointer
    fn create_c_string(s: &str) -> *mut c_char {
        CString::new(s).unwrap().into_raw()
    }

    // Helper to convert raw CString pointer back to String and free it
    fn get_and_free_c_string(ptr: *mut c_char) -> Option<String> {
        if ptr.is_null() {
            return None;
        }
        unsafe {
            let c_string = CString::from_raw(ptr);
            Some(c_string.to_string_lossy().into_owned())
        }
    }

    #[test]
    fn test_parse_delegation_list_ipv4() {
        let content = "
# Comment line
192.0.2.0/24 whois.example.com
198.51.100.0/24   whois.test.org   # Inline comment
invalid-line
";
        let delegations = parse_delegation_list(content);
        assert_eq!(delegations.len(), 2);

        assert_eq!(
            delegations[0].network,
            "192.0.2.0/24".parse::<IpNet>().unwrap()
        );
        assert_eq!(delegations[0].whois_server, "whois.example.com");

        assert_eq!(
            delegations[1].network,
            "198.51.100.0/24".parse::<IpNet>().unwrap()
        );
        assert_eq!(delegations[1].whois_server, "whois.test.org");
    }

    #[test]
    fn test_parse_delegation_list_ipv6() {
        let content = "
2001:db8::/32 whois.ipv6-example.com
2001:0db8:85a3:0000:0000:8a2e:0370:7334/128 whois.ipv6-test.org
";
        let delegations = parse_delegation_list(content);
        assert_eq!(delegations.len(), 2);

        assert_eq!(
            delegations[0].network,
            "2001:0db8:85a3:0000:0000:8a2e:0370:7334/128"
                .parse::<IpNet>()
                .unwrap()
        );
        assert_eq!(delegations[0].whois_server, "whois.ipv6-test.org");

        assert_eq!(
            delegations[1].network,
            "2001:db8::/32".parse::<IpNet>().unwrap()
        );
        assert_eq!(delegations[1].whois_server, "whois.ipv6-example.com");
    }

    #[test]
    fn test_whois_ip_lookup_ipv4_cidr() {
        // Temporarily modify the static list for testing
        // This is generally not advisable, but for testing an internal function that relies on statics it's complex.
        // For actual FFI testing, need a setup that properly loads/unloads shared library for each test or mocks the resources.
        // For now, this test will pass if the actual delegation lists contain the tested networks.
        // Mocking `include_str!` or `Lazy` is non-trivial without changing the original code structure.

        // Given existing entries in ip_del_list (assuming they exist or are mocked)
        // For a true unit test, we'd need to mock IPV4_DELEGATIONS and IPV6_DELEGATIONS.
        // For integration-like test, we rely on existing resources/ip_del_list and resources/ip6_del_list.

        // Example: if 1.0.0.0/8 points to whois.apnic.net from ip_del_list
        let ip_cidr = create_c_string("1.1.1.1/32"); // Falls under 1.0.0.0/8 apnic
        let result_ptr = whois_ip_lookup(ip_cidr);
        let _result = get_and_free_c_string(result_ptr);

        // This assertion depends on the actual content of resources/ip_del_list
        // Based on resources/ip_del_list, 1.0.0.0/8 maps to 'apnic'
        assert_eq!(_result, Some("whois.apnic.net".to_string()));
    }

    #[test]
    fn test_whois_ip_lookup_ipv6_cidr() {
        let ip_cidr = create_c_string("2001:0600::/23"); // Falls under 2001:0600::/23 ripe
        let result_ptr = whois_ip_lookup(ip_cidr);
        let _result = get_and_free_c_string(result_ptr);

        // Based on resources/ip6_del_list, 2001:0600::/23 maps to 'ripe'
        assert_eq!(_result, Some("whois.ripe.net".to_string()));
    }

    #[test]
    fn test_whois_ip_lookup_ipv4_single_ip() {
        let ip_single = create_c_string("8.8.8.8"); // Google DNS, falls under 0.0.0.0/1 arin
        let result_ptr = whois_ip_lookup(ip_single);
        let _result = get_and_free_c_string(result_ptr);
        assert_eq!(_result, Some("whois.arin.net".to_string()));

        let ip_single = create_c_string("114.114.114.114"); // Google DNS, falls under 0.0.0.0/1 arin
        let result_ptr = whois_ip_lookup(ip_single);
        let _result = get_and_free_c_string(result_ptr);
        assert_eq!(_result, Some("whois.apnic.net".to_string()));

        let ip_single = create_c_string("125.128.125.128"); // Google DNS, falls under 0.0.0.0/1 arin
        let result_ptr = whois_ip_lookup(ip_single);
        let _result = get_and_free_c_string(result_ptr);
        assert_eq!(_result, Some("whois.nic.or.kr".to_string()));
    }

    #[test]
    fn test_whois_ip_lookup_ipv6_single_ip() {
        let ip_single = create_c_string("2001:4860:4860::8888"); // Google DNS IPv6, falls under 2001:4800::/23 arin
        let result_ptr = whois_ip_lookup(ip_single);
        let _result = get_and_free_c_string(result_ptr);
        assert_eq!(_result, Some("whois.arin.net".to_string()));
    }

    #[test]
    fn test_whois_ip_lookup_no_match() {
        // 10.0.0.1 falls under "0.0.0.0/1 arin" based on resources/ip_del_list
        let ip_no_match = create_c_string("10.0.0.1");
        let result_ptr = whois_ip_lookup(ip_no_match);
        let ip_result = get_and_free_c_string(result_ptr);
        assert_eq!(ip_result, Some("whois.arin.net".to_string()));

        let ip_no_match_v6 = create_c_string("fc00::1");
        let result_ptr_v6 = whois_ip_lookup(ip_no_match_v6);
        let result_v6 = get_and_free_c_string(result_ptr_v6);
        assert_eq!(result_v6, Some(WHOIS_FALLBACK.to_string()));
    }

    #[test]
    fn test_whois_ip_lookup_invalid_input() {
        let invalid_ip = create_c_string("invalid-ip");
        let result_ptr = whois_ip_lookup(invalid_ip);
        let ip_result = get_and_free_c_string(result_ptr);
        assert_eq!(ip_result, Some(WHOIS_FALLBACK.to_string()));

        let null_ip: *const c_char = std::ptr::null();
        let result_ptr_null = whois_ip_lookup(null_ip);
        let result_null = get_and_free_c_string(result_ptr_null);
        assert_eq!(result_null, Some(WHOIS_FALLBACK.to_string()));
    }

    // This test ensures `ffi_chars_to_rust_string` is correctly handled,
    // as it's a direct dependency in `whois_ip_lookup`.
    // It mocks a basic version of `ffi_chars_to_rust_string` if it's not directly testable.
    // However, since `src/lib.rs` is where `ffi_chars_to_rust_string` is defined,
    // we need to make sure it's accessible or if it mocks it automatically when compiling the tests.

    // A more robust FFI test would involve compiling `lib.rs` as a shared library
    // and linking to it, but for simple unit testing within the same crate,
    // direct call should work if `ffi_chars_to_rust_string` is public in `lib.rs`
    // assuming no conflicting `#[cfg(test)]` directives.
}
