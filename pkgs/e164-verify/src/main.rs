mod caller_id;
mod e164;
mod naptr;
mod resolve;
mod result;
mod sip_uri;
mod source_ip;

use std::io::{self, BufRead, Read};


use c_ares_resolver::BlockingResolver;
use clap::Parser;

use caller_id::parse_caller_id;
use e164::build_e164_domain;
use naptr::naptr_sip_hosts;
use resolve::resolve_sip_ips;
use result::VerifyResult;
use source_ip::parse_source_ip;

/// Verify that a SIP caller's source IP matches an e164.dn42 DNS entry.
///
/// AGI script: reads Key: Value environment lines from stdin until a blank
/// line, then writes `SET VARIABLE ENUM_VERIFY_RESULT "<result>"` to stdout.
///
/// Result values:
///   PASS              — source IP is a registered SIP server for this number
///   SPOOFED           — number found in DNS but IP did not match any server
///   NO_ENUM_RECORD    — no NAPTR record found for this number
///   ERROR_INVALID_IP  — could not parse the source IP argument
///   ERROR_INVALID_NUMBER — could not extract digits from the caller ID
#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    /// SIP caller ID. Accepted formats:
    ///   12345678
    ///   12345678@example.com
    ///   Caller Name <12345678@example.com>
    caller_id: String,

    /// Source IP address (IPv4 or IPv6), optionally with port.
    /// Examples: 1.2.3.4  1.2.3.4:5060  ::1  [::1]:5060
    source_ip: String,
}

fn main() {
    let args = Args::parse();

    let stdin = io::stdin();
    let mut stdin = stdin.lock();

    // Drain the AGI environment block (Key: Value lines until blank).
    for line in stdin.by_ref().lines() {
        match line {
            Ok(l) if l.trim().is_empty() => break,
            Ok(_) => {}
            Err(_) => break,
        }
    }

    let result = run(args);

    // Write the AGI SET VARIABLE command.
    println!("SET VARIABLE ENUM_VERIFY_RESULT \"{}\"", result);

    // Read Asterisk's response line (e.g. "200 result=1").
    let mut response = String::new();
    let _ = stdin.read_line(&mut response);
    eprintln!("AGI response: {}", response.trim());
}

fn run(args: Args) -> VerifyResult {
    // 1. Parse caller ID → digits
    let digits = match parse_caller_id(&args.caller_id) {
        Ok(d) => d,
        Err(e) => {
            eprintln!("Error parsing caller ID: {:#}", e);
            return VerifyResult::ErrorInvalidNumber;
        }
    };

    // 2. Parse source IP
    let source_ip = match parse_source_ip(&args.source_ip) {
        Ok(ip) => ip,
        Err(e) => {
            eprintln!("Error parsing source IP: {:#}", e);
            return VerifyResult::ErrorInvalidIp;
        }
    };

    // 3. Build e164.dn42 query domain
    let domain = build_e164_domain(&digits);
    eprintln!("Querying NAPTR records for: {}", domain);
    eprintln!("Source IP to verify: {}", source_ip);

    // 4. Create c-ares blocking resolver (reads /etc/resolv.conf automatically).
    let resolver = match BlockingResolver::new() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Failed to create resolver: {}", e);
            return VerifyResult::NoEnumRecord;
        }
    };

    // 5. Query NAPTR and extract SIP hosts.
    let sip_hosts = match naptr_sip_hosts(&resolver, &domain) {
        Some(h) => h,
        None => {
            eprintln!("No SIP NAPTR records found for {}", domain);
            return VerifyResult::NoEnumRecord;
        }
    };

    // 6. Resolve each SIP host to IPs and check against source IP.
    for host in &sip_hosts {
        let resolved = resolve_sip_ips(&resolver, host);
        for ip in &resolved {
            eprintln!("  Resolved {} → {}", host, ip);
            if *ip == source_ip {
                eprintln!("  ✓ Match found!");
                return VerifyResult::Pass;
            }
        }
    }

    VerifyResult::Spoofed
}
