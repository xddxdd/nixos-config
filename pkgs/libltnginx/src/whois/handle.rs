use lazy_static::lazy_static;
use std::collections::HashMap;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::Mutex;

use crate::whois::abbr::{WHOIS_FALLBACK, lookup_abbr};

lazy_static! {
    static ref NIC_HANDLES_MAP: Mutex<HashMap<String, String>> = {
        let mut map = HashMap::new();
        let content = include_str!("../../resources/nic_handles_list");
        for line in content.lines() {
            if let Some(pos) = line.find('\t') {
                let suffix = line[..pos].trim_start_matches('-').to_lowercase();
                let server = line[pos + 1..].trim().to_string();
                map.insert(suffix, server);
            }
        }
        Mutex::new(map)
    };
}

#[unsafe(no_mangle)]
pub extern "C" fn whois_nic_handle_lookup(name: *const c_char) -> *const c_char {
    let c_str = unsafe { CStr::from_ptr(name) };
    let name_str = c_str.to_str().expect("Invalid UTF-8 string");
    let lower_name = name_str.to_lowercase();

    let nic_handles_map = NIC_HANDLES_MAP.lock().unwrap();

    for (suffix, server) in nic_handles_map.iter() {
        if lower_name.ends_with(suffix) {
            let mapped_server = lookup_abbr(server).unwrap_or(server);
            let c_string = CString::new(mapped_server).expect("Failed to create CString");
            return c_string.into_raw();
        }
    }

    CString::new(WHOIS_FALLBACK).unwrap().into_raw()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::free_string;
    use std::ffi::CString;

    #[test]
    fn test_whois_nic_handle_lookup_found() {
        // Test with a known handle
        let handle_name = CString::new("test-arin").expect("CString::new failed");
        let result_ptr = whois_nic_handle_lookup(handle_name.as_ptr());
        assert!(!result_ptr.is_null());
        let result_c_str = unsafe { CStr::from_ptr(result_ptr) };
        assert_eq!(result_c_str.to_str().unwrap(), "whois.arin.net");
        unsafe { free_string(result_ptr as *mut c_char) };

        let handle_name = CString::new("Test-lACNIC").expect("CString::new failed");
        let result_ptr = whois_nic_handle_lookup(handle_name.as_ptr());
        assert!(!result_ptr.is_null());
        let result_c_str = unsafe { CStr::from_ptr(result_ptr) };
        assert_eq!(result_c_str.to_str().unwrap(), "whois.lacnic.net");
        unsafe { free_string(result_ptr as *mut c_char) };
    }

    #[test]
    fn test_whois_nic_handle_lookup_not_found() {
        // Test with an unknown handle
        let handle_name = CString::new("unknown").expect("CString::new failed");
        let result_ptr = whois_nic_handle_lookup(handle_name.as_ptr());
        assert!(!result_ptr.is_null());
        let result_c_str = unsafe { CStr::from_ptr(result_ptr) };
        assert_eq!(result_c_str.to_str().unwrap(), WHOIS_FALLBACK);
        unsafe { free_string(result_ptr as *mut c_char) };

        let handle_name = CString::new("not-a-nic-handle").expect("CString::new failed");
        let result_ptr = whois_nic_handle_lookup(handle_name.as_ptr());
        assert!(!result_ptr.is_null());
        let result_c_str = unsafe { CStr::from_ptr(result_ptr) };
        assert_eq!(result_c_str.to_str().unwrap(), WHOIS_FALLBACK);
        unsafe { free_string(result_ptr as *mut c_char) };
    }

    #[test]
    fn test_whois_nic_handle_lookup_empty_string() {
        // Test with an empty string
        let handle_name = CString::new("").expect("CString::new failed");
        let result_ptr = whois_nic_handle_lookup(handle_name.as_ptr());
        assert!(!result_ptr.is_null());
        let result_c_str = unsafe { CStr::from_ptr(result_ptr) };
        assert_eq!(result_c_str.to_str().unwrap(), WHOIS_FALLBACK);
        unsafe { free_string(result_ptr as *mut c_char) };
    }
}
