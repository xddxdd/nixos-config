use std::ffi::{CStr, CString};
use std::os::raw::c_char;

mod whois;

pub use crate::whois::asn::whois_asn_lookup;
pub use crate::whois::domain::whois_domain_lookup;
pub use crate::whois::handle::whois_nic_handle_lookup;
pub use crate::whois::ip::whois_ip_lookup;

#[unsafe(no_mangle)]
pub unsafe extern "C" fn free_string(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    unsafe {
        let _ = CString::from_raw(ptr);
    }
}

/// Converts a C-style string (char*) to a Rust Option<String>.
/// If the input pointer is null, it returns None.
/// Otherwise, it safely converts the CStr to a Rust String.
pub fn ffi_chars_to_rust_string(ptr: *const c_char) -> Option<String> {
    if ptr.is_null() {
        return None;
    }
    Some(
        unsafe { CStr::from_ptr(ptr) }
            .to_string_lossy()
            .into_owned(),
    )
}
