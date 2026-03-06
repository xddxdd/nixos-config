use std::net::IpAddr;
use std::str::FromStr;

use c_ares_resolver::BlockingResolver;

/// Resolve all IP addresses for a SIP server hostname using c-ares.
///
/// Resolution strategy (results are deduplicated):
///   1. Direct A record lookup (IPv4)
///   2. Direct AAAA record lookup (IPv6)
///   3. SIP SRV records: `_sip._udp.<host>` and `_sip._tcp.<host>`
///      For each SRV target, resolve A + AAAA records.
pub fn resolve_sip_ips(resolver: &BlockingResolver, host: &str) -> Vec<IpAddr> {
    // If the host is already an IP literal, return it directly.
    if let Ok(ip) = IpAddr::from_str(host) {
        return vec![ip];
    }

    let mut ips: Vec<IpAddr> = Vec::new();

    // 1 + 2. Explicit A and AAAA lookups.
    resolve_a_aaaa(resolver, host, &mut ips);

    // 3. SIP SRV records.
    for prefix in &["_sip._udp", "_sip._tcp"] {
        let srv_name = format!("{}.{}", prefix, host);
        resolve_srv(resolver, &srv_name, &mut ips);
    }

    dedup(&mut ips);
    ips
}

/// Look up A and AAAA records for `host` and append addresses to `out`.
fn resolve_a_aaaa(resolver: &BlockingResolver, host: &str, out: &mut Vec<IpAddr>) {
    match resolver.query_a(host) {
        Ok(results) => {
            for result in &results {
                out.push(IpAddr::V4(result.ipv4()));
            }
        }
        Err(e) => eprintln!("  Warning: A lookup for {} failed: {}", host, e),
    }

    match resolver.query_aaaa(host) {
        Ok(results) => {
            for result in &results {
                out.push(IpAddr::V6(result.ipv6()));
            }
        }
        Err(e) => eprintln!("  Warning: AAAA lookup for {} failed: {}", host, e),
    }
}

/// Look up SRV records at `srv_name`, then resolve each target's A + AAAA.
fn resolve_srv(resolver: &BlockingResolver, srv_name: &str, out: &mut Vec<IpAddr>) {
    let results = match resolver.query_srv(srv_name) {
        Ok(r) => r,
        Err(_) => return, // SRV absent — silently skip
    };

    for result in &results {
        let target = result.host().trim_end_matches('.');
        if target.is_empty() || target == "." {
            continue;
        }
        eprintln!("  SRV {} → {}", srv_name, target);
        resolve_a_aaaa(resolver, target, out);
    }
}

/// Deduplicate IPs in place (sort → dedup).
fn dedup(ips: &mut Vec<IpAddr>) {
    ips.sort_unstable_by_key(|ip| match ip {
        IpAddr::V4(v4) => (0u8, v4.octets().to_vec(), vec![]),
        IpAddr::V6(v6) => (1u8, vec![], v6.octets().to_vec()),
    });
    ips.dedup();
}
