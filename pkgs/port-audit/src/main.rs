// Audit local listening sockets against the configured zone local-port
// allowlist, and pin the kernel ephemeral port range that the firewall rules
// assume.
//
// All inputs are environment variables (injected by the host-specific wrapper
// from eval-time config; no live nftables query, no argv):
// - PORT_AUDIT_ALLOWED: comma-separated port specs, `22` or `20000-23999`,
//   copied verbatim from every enabled zone's tcpPorts/udpPorts entries whose
//   type is "local"
// - PORT_AUDIT_ADDITIONAL: comma-separated port specs copied verbatim from
//   lantian.firewall.presets.public-firewall.allowedInternalPorts on
//   non-firewalled hosts; LTnet-only listeners that must never
//   appear in PORT_AUDIT_ALLOWED (asserted at eval time and re-checked here)
// - PORT_AUDIT_KNOWN_VIOLATIONS: comma-separated port specs copied verbatim
//   from lantian.port-audit.knownViolations; listeners on public or wildcard
//   addresses that the firewall deliberately keeps closed (asserted at eval
//   time not to overlap any zone's local ports)
// - PORT_AUDIT_EPHEMERAL: expected `lo-hi` ephemeral port range (defaults to
//   the kernel/repo baseline 32768-60999 when unset)
// - PORT_AUDIT_RESERVED_V4 / PORT_AUDIT_RESERVED_V6: comma-separated CIDRs
//   copied from LT.constants.reserved; addresses inside these (plus kernel
//   loopback/link-local/multicast classes) are internal, not public-facing
// - /proc/sys/net/ipv4/ip_local_port_range for the live ephemeral port range
// - /proc/net/{tcp,tcp6,udp,udp6} for listening sockets
// - /proc/<pid>/fd for attributing a violating socket inode to a process
//   (only scanned when a violation is found; needs root to see other users)
//
// Exit codes: 0 = clean, 1 = audit violations found, 2 = could not gather data.
use std::collections::HashMap;
use std::fmt::Write as _;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::process::exit;

const EPHEMERAL_MIN: u16 = 32768;
const EPHEMERAL_MAX: u16 = 60999;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Proto {
    Tcp,
    Udp,
}

impl Proto {
    fn label(self) -> &'static str {
        match self {
            Proto::Tcp => "tcp",
            Proto::Udp => "udp",
        }
    }
}

#[derive(Debug)]
struct Listener {
    proto: Proto,
    addr: IpAddr,
    port: u16,
    inode: u64,
}

// A reserved-source entry, as accepted or excluded from the audit. CIDRs are
// stored as inclusive address ranges so both exact addrs and prefixes share
// one matcher.
#[derive(Debug, Clone, Copy)]
enum AddrRange {
    V4 { lo: u32, hi: u32 },
    V6 { lo: u128, hi: u128 },
}

impl AddrRange {
    fn contains(&self, addr: &IpAddr) -> bool {
        match (self, addr) {
            (AddrRange::V4 { lo, hi }, IpAddr::V4(v4)) => {
                let v = u32::from(*v4);
                v >= *lo && v <= *hi
            }
            (AddrRange::V6 { lo, hi }, IpAddr::V6(v6)) => {
                let v = u128::from(*v6);
                v >= *lo && v <= *hi
            }
            _ => false,
        }
    }
}

fn v4_range(lo: Ipv4Addr, hi: Ipv4Addr) -> AddrRange {
    AddrRange::V4 {
        lo: u32::from(lo),
        hi: u32::from(hi),
    }
}

fn v6_range(lo: Ipv6Addr, hi: Ipv6Addr) -> AddrRange {
    AddrRange::V6 {
        lo: u128::from(lo),
        hi: u128::from(hi),
    }
}

// One inclusive port range parsed from an argv spec.
#[derive(Debug, Clone, Copy)]
struct PortRange {
    lo: u16,
    hi: u16,
}

impl PortRange {
    fn contains(&self, p: u16) -> bool {
        p >= self.lo && p <= self.hi
    }
}

// Comma-separated port specs, `22` or `20000-23999`. `required=true` rejects a
// missing env var as a hard error; the optional vars just default to empty.
fn parse_port_specs(name: &str, required: bool) -> (Vec<PortRange>, Vec<String>) {
    let v = match std::env::var(name) {
        Ok(v) => v,
        Err(_) => {
            if required {
                return (
                    Vec::new(),
                    vec![format!(
                        "env {name} missing; the wrapper must inject this list"
                    )],
                );
            }
            return (Vec::new(), Vec::new());
        }
    };
    let specs = v
        .split(',')
        .filter(|s| !s.trim().is_empty())
        .map(|a| {
            let a = a.trim();
            if let Some((lo, hi)) = a.split_once('-') {
                match (lo.parse::<u16>(), hi.parse::<u16>()) {
                    (Ok(l), Ok(h)) => Ok(PortRange { lo: l, hi: h }),
                    _ => Err(format!(
                        "env {name}: malformed port spec `{a}` (expect `<lo>-<hi>`)"
                    )),
                }
            } else {
                match a.parse::<u16>() {
                    Ok(p) => Ok(PortRange { lo: p, hi: p }),
                    Err(_) => Err(format!(
                        "env {name}: malformed port spec `{a}` (expect `<port>`)"
                    )),
                }
            }
        })
        .collect::<Result<Vec<PortRange>, String>>();
    match specs {
        Ok(list) => (list, Vec::new()),
        Err(e) => (Vec::new(), vec![e]),
    }
}

fn main() {
    let mut hard_errors: Vec<String> = Vec::new();
    let mut violations: Vec<String> = Vec::new();
    let mut info: Vec<String> = Vec::new();

    // --- inputs: allowed ports, LTnet-only ports, ephemeral expectation -------
    let (allowed_ports, parse_errors) = parse_port_specs("PORT_AUDIT_ALLOWED", true);
    hard_errors.extend(parse_errors);
    info.push(format!(
        "allowed ports: {} spec(s) from env",
        allowed_ports.len()
    ));
    let (additional_ports, parse_errors) = parse_port_specs("PORT_AUDIT_ADDITIONAL", false);
    hard_errors.extend(parse_errors);
    info.push(format!(
        "additional LTnet-only ports: {} spec(s) from env",
        additional_ports.len()
    ));
    let (known_violations, parse_errors) = parse_port_specs("PORT_AUDIT_KNOWN_VIOLATIONS", false);
    hard_errors.extend(parse_errors);
    info.push(format!(
        "known-violation ports: {} spec(s) from env",
        known_violations.len()
    ));
    // The Nix assertion already rejects overlaps; re-checking here catches
    // drifted wrappers where the env vars no longer match eval-time config.
    for a in &additional_ports {
        if allowed_ports.iter().any(|r| r.lo <= a.hi && a.lo <= r.hi) {
            hard_errors.push(format!(
                "additional LTnet-only port {}-{} also allowed by the firewall; configs are inconsistent",
                a.lo, a.hi
            ));
        }
    }

    let expected_ephemeral = match std::env::var("PORT_AUDIT_EPHEMERAL") {
        Ok(v) => match v.trim().split_once('-') {
            Some((lo, hi)) => match (lo.trim().parse::<u16>(), hi.trim().parse::<u16>()) {
                (Ok(l), Ok(h)) => (l, h),
                _ => (EPHEMERAL_MIN, EPHEMERAL_MAX),
            },
            None => (EPHEMERAL_MIN, EPHEMERAL_MAX),
        },
        Err(_) => (EPHEMERAL_MIN, EPHEMERAL_MAX),
    };

    let mut reserved: Vec<AddrRange> = Vec::new();
    for (var, family) in [
        ("PORT_AUDIT_RESERVED_V4", "v4"),
        ("PORT_AUDIT_RESERVED_V6", "v6"),
    ] {
        match std::env::var(var) {
            Ok(v) => {
                for cidr in v.split(',').filter(|s| !s.is_empty()) {
                    match parse_cidr(cidr) {
                        Ok(r) => reserved.push(r),
                        Err(e) => hard_errors.push(format!("env {var}: {e}")),
                    }
                }
            }
            Err(_) => hard_errors.push(format!(
                "env {var} missing; the service unit must inject the reserved-{family} CIDR list"
            )),
        }
    }

    // --- 1. ephemeral port range -----------------------------------------------
    match std::fs::read_to_string("/proc/sys/net/ipv4/ip_local_port_range") {
        Ok(text) => {
            let mut parts = text.split_whitespace();
            let lo = parts.next().and_then(|v| v.parse::<u16>().ok());
            let hi = parts.next().and_then(|v| v.parse::<u16>().ok());
            match (lo, hi) {
                (Some(l), Some(h)) if l == expected_ephemeral.0 && h == expected_ephemeral.1 => {
                    info.push(format!("ephemeral port range {l}-{h}: OK"))
                }
                (lo, hi) => violations.push(format!(
                    "ephemeral port range: expected {}-{}, got {}-{}",
                    expected_ephemeral.0,
                    expected_ephemeral.1,
                    lo.map_or("?".to_string(), |v| v.to_string()),
                    hi.map_or("?".to_string(), |v| v.to_string()),
                )),
            }
        }
        Err(e) => hard_errors.push(format!("cannot read ip_local_port_range: {e}")),
    }

    // --- 2. listeners -----------------------------------------------------------
    let mut listeners: Vec<Listener> = Vec::new();
    let mut counts = String::new();
    for (path, proto) in [
        ("/proc/net/tcp", Proto::Tcp),
        ("/proc/net/tcp6", Proto::Tcp),
        ("/proc/net/udp", Proto::Udp),
        ("/proc/net/udp6", Proto::Udp),
    ] {
        match parse_sockets(path, proto) {
            Ok(list) => {
                let _ = write!(
                    counts,
                    "{}{}={}",
                    if counts.is_empty() { "" } else { " " },
                    path.rsplit('/').next().unwrap_or(path),
                    list.len()
                );
                listeners.extend(list);
            }
            Err(e) => hard_errors.push(format!("cannot read {path}: {e}")),
        }
    }
    if !counts.is_empty() {
        info.push(format!("listening sockets: {counts}"));
    }

    if hard_errors.is_empty() {
        let mut offending: Vec<Listener> = Vec::new();
        for l in listeners {
            // Loopback, link-local and multicast bindings never face the
            // public Internet and are never covered by the allowlist.
            if l.addr.is_loopback() || is_link_local(&l.addr) || l.addr.is_multicast() {
                continue;
            }
            // Wildcard binds cover every interface (including any public one);
            // specific binds only matter when the address itself is public.
            let public_facing = matches!(l.addr, IpAddr::V4(Ipv4Addr::UNSPECIFIED))
                || matches!(l.addr, IpAddr::V6(v6) if v6 == Ipv6Addr::UNSPECIFIED)
                || !reserved.iter().any(|r| r.contains(&l.addr));
            if !public_facing {
                continue;
            }
            if allowed_ports.iter().any(|r| r.contains(l.port)) {
                continue;
            }
            if additional_ports.iter().any(|r| r.contains(l.port)) {
                continue; // expected LTnet-only listener, WAN-blocked by policy
            }
            // Recorded exceptions: public or wildcard binds that the firewall
            // keeps closed. The eval-time assertion rejects overlap with
            // either allowlist.
            if known_violations.iter().any(|r| r.contains(l.port)) {
                continue;
            }
            // Ephemeral-range listeners are already accepted from WAN by the
            // ephemeral rules and are exempted from the audit per policy.
            if (expected_ephemeral.0..=expected_ephemeral.1).contains(&l.port) {
                continue;
            }
            offending.push(l);
        }
        if !offending.is_empty() {
            let owners = socket_owners();
            for l in offending {
                let owner = match owners.get(&l.inode) {
                    Some((pid, name)) => format!("; owner: {name} (pid {pid})"),
                    None => "; owner: unknown".to_string(),
                };
                violations.push(format!(
                    "VIOLATION: {} {}:{} is listening on a public or wildcard address but not in the allowed-port list{owner}",
                    l.proto.label(),
                    l.addr,
                    l.port,
                ));
            }
            violations.sort();
            violations.dedup();
        }
    }

    for line in &info {
        println!("port-audit: {line}");
    }
    for line in &hard_errors {
        eprintln!("port-audit: ERROR: {line}");
    }
    for line in &violations {
        println!("port-audit: {line}");
    }
    if hard_errors.is_empty() {
        println!(
            "port-audit: summary: {} violation{}",
            violations.len(),
            if violations.len() == 1 { "" } else { "s" }
        );
    }
    if !hard_errors.is_empty() {
        exit(2);
    }
    if !violations.is_empty() {
        exit(1);
    }
}

fn is_link_local(addr: &IpAddr) -> bool {
    match addr {
        // Ipv4Addr::is_link_local / Ipv6Addr::is_unicast_link_local exist
        // separately; IpAddr has no combined accessor.
        IpAddr::V4(v4) => v4.is_link_local(), // 169.254.0.0/16
        IpAddr::V6(v6) => v6.is_unicast_link_local(), // fe80::/10
    }
}

// `a/b/p` → inclusive range; a plain address behaves as a /32 or /128.
fn parse_cidr(token: &str) -> Result<AddrRange, String> {
    let bad = || format!("malformed CIDR `{token}`");
    match token.split_once('/') {
        Some((addr, prefix)) => {
            let prefix: u8 = prefix.parse().map_err(|_| bad())?;
            match addr.parse::<IpAddr>() {
                Ok(IpAddr::V4(a)) if prefix <= 32 => {
                    let m = mask4(prefix);
                    let lo = u32::from(a) & m;
                    Ok(v4_range(Ipv4Addr::from(lo), Ipv4Addr::from(lo | !m)))
                }
                Ok(IpAddr::V6(a)) if prefix <= 128 => {
                    let m = mask6(prefix);
                    let lo = u128::from(a) & m;
                    Ok(v6_range(Ipv6Addr::from(lo), Ipv6Addr::from(lo | !m)))
                }
                _ => Err(bad()),
            }
        }
        None => match token.parse::<IpAddr>() {
            Ok(a) => Ok(match a {
                IpAddr::V4(v4) => v4_range(v4, v4),
                IpAddr::V6(v6) => v6_range(v6, v6),
            }),
            Err(_) => Err(bad()),
        },
    }
}

fn mask4(prefix: u8) -> u32 {
    if prefix == 0 {
        0
    } else {
        u32::MAX << (32 - prefix as u32)
    }
}

fn mask6(prefix: u8) -> u128 {
    if prefix == 0 {
        0
    } else {
        u128::MAX << (128 - prefix as u32)
    }
}

/// Parses listening sockets from a /proc/net/{tcp,tcp6,udp,udp6} file.
/// TCP listening = state 0A; UDP listening = bound with unspecified remote.
fn parse_sockets(path: &str, proto: Proto) -> Result<Vec<Listener>, String> {
    let content = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
    let mut out = Vec::new();
    for (i, line) in content.lines().enumerate() {
        let line = line.trim();
        if i == 0 || line.is_empty() {
            continue; // header line
        }
        let fields: Vec<&str> = line.split_whitespace().collect();
        if fields.len() < 4 {
            return Err(format!("line {}: unexpected format", i + 1));
        }
        let local = fields[1];
        let rem = fields[2];
        let st = fields[3];
        let is_tcp = proto == Proto::Tcp;
        if is_tcp && !matches!(st, "0A" | "0a") {
            continue;
        }
        if !is_tcp
            && !matches!(
                rem.to_lowercase().as_str(),
                "00000000:0000" | "00000000000000000000000000000000:0000"
            )
        {
            continue;
        }
        let Some((hex_addr, hex_port)) = local.rsplit_once(':') else {
            return Err(format!("line {}: malformed local address `{local}`", i + 1));
        };
        let port = u16::from_str_radix(hex_port, 16)
            .map_err(|_| format!("line {}: malformed port `{hex_port}`", i + 1))?;
        let addr = parse_hex_addr(hex_addr)
            .ok_or_else(|| format!("line {}: malformed address `{hex_addr}`", i + 1))?;
        let inode = fields
            .get(9)
            .and_then(|v| v.parse::<u64>().ok())
            .unwrap_or(0);
        out.push(Listener {
            proto,
            addr,
            port,
            inode,
        });
    }
    Ok(out)
}

/// Maps socket inode -> (pid, process name) for the lowest pid holding that
/// socket. Forked workers share the listening socket, so the lowest pid is the
/// master/parent and the most useful attribution.
fn socket_owners() -> HashMap<u64, (u32, String)> {
    let mut owners: HashMap<u64, (u32, String)> = HashMap::new();
    let Ok(entries) = std::fs::read_dir("/proc") else {
        return owners;
    };
    for entry in entries.flatten() {
        let Some(pid) = entry
            .file_name()
            .to_str()
            .and_then(|s| s.parse::<u32>().ok())
        else {
            continue;
        };
        let Ok(fds) = std::fs::read_dir(format!("/proc/{pid}/fd")) else {
            continue;
        };
        let mut name: Option<String> = None;
        for fd in fds.flatten() {
            let Ok(target) = std::fs::read_link(fd.path()) else {
                continue;
            };
            let Some(inode) = target
                .to_str()
                .and_then(|t| t.strip_prefix("socket:[")?.strip_suffix(']'))
                .and_then(|t| t.parse::<u64>().ok())
            else {
                continue;
            };
            let name = name.get_or_insert_with(|| process_name(pid));
            owners
                .entry(inode)
                .and_modify(|e| {
                    if pid < e.0 {
                        *e = (pid, name.clone());
                    }
                })
                .or_insert_with(|| (pid, name.clone()));
        }
    }
    owners
}

fn process_name(pid: u32) -> String {
    if let Ok(comm) = std::fs::read_to_string(format!("/proc/{pid}/comm")) {
        let comm = comm.trim();
        if !comm.is_empty() {
            return comm.to_string();
        }
    }
    std::fs::read_link(format!("/proc/{pid}/exe"))
        .ok()
        .and_then(|p| p.file_name().map(|n| n.to_string_lossy().into_owned()))
        .unwrap_or_else(|| "?".to_string())
}

// /proc/net addresses are 32-bit words printed in host (little-endian) order;
// each 8-hex-char group expands via to_le_bytes into the next 4 address bytes.
fn parse_hex_addr(hex: &str) -> Option<IpAddr> {
    match hex.len() {
        8 => {
            let v = u32::from_str_radix(hex, 16).ok()?;
            let b = v.to_le_bytes();
            Some(IpAddr::V4(Ipv4Addr::new(b[0], b[1], b[2], b[3])))
        }
        32 => {
            let mut bytes = [0u8; 16];
            for (i, group) in hex.as_bytes().chunks_exact(8).enumerate() {
                let s = std::str::from_utf8(group).ok()?;
                let v = u32::from_str_radix(s, 16).ok()?;
                bytes[i * 4..i * 4 + 4].copy_from_slice(&v.to_le_bytes());
            }
            let v6 = Ipv6Addr::from(bytes);
            // IPv4-mapped IPv6 binds (::ffff:a.b.c.d) have IPv4 semantics;
            // classify them as plain IPv4 so loopback checks apply.
            match v6.to_ipv4_mapped() {
                Some(v4) => Some(IpAddr::V4(v4)),
                None => Some(IpAddr::V6(v6)),
            }
        }
        _ => None,
    }
}
