use std::fs;
use std::io::Write;
use std::path::Path;

fn parse_ip_delegation_list(content: &str) -> Vec<(String, String)> {
    content
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

                // Validate network_str by parsing it. Required for sorting.
                if network_str.parse::<ipnet::IpNet>().is_ok() {
                    return Some((network_str.to_string(), whois_server));
                }
            }
            None
        })
        .collect()
}

pub fn generate_ip_delegations(
    manifest_dir: &Path,
    out_dir: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let dest_path = out_dir.join("generated_ip_delegations.rs");
    let mut generated_file =
        fs::File::create(&dest_path).expect("Could not create output file for IP delegations.");

    let ip_del_list_path = manifest_dir.join("resources/ip_del_list");
    let ipv4_content =
        fs::read_to_string(&ip_del_list_path).expect("Could not read ip_del_list file.");

    let ip6_del_list_path = manifest_dir.join("resources/ip6_del_list");
    let ipv6_content =
        fs::read_to_string(&ip6_del_list_path).expect("Could not read ip6_del_list file.");

    let mut ipv4_delegations: Vec<(String, String)> = parse_ip_delegation_list(&ipv4_content);
    let mut ipv6_delegations: Vec<(String, String)> = parse_ip_delegation_list(&ipv6_content);

    // Sort by prefix length (longest first)
    ipv4_delegations.sort_by(|a, b| {
        let net_a = a.0.parse::<ipnet::IpNet>().unwrap();
        let net_b = b.0.parse::<ipnet::IpNet>().unwrap();
        net_b.prefix_len().cmp(&net_a.prefix_len())
    });
    ipv6_delegations.sort_by(|a, b| {
        let net_a = a.0.parse::<ipnet::IpNet>().unwrap();
        let net_b = b.0.parse::<ipnet::IpNet>().unwrap();
        net_b.prefix_len().cmp(&net_a.prefix_len())
    });

    writeln!(generated_file, "#[allow(dead_code)]")
        .expect("Could not write to IP delegations output file.");
    writeln!(generated_file, "#[allow(clippy::unreadable_literal)]")
        .expect("Could not write to IP delegations output file.");
    writeln!(generated_file, "").expect("Could not write to IP delegations output file.");

    writeln!(
        generated_file,
        "const IPV4_DELEGATIONS_RAW: &[(&'static str, &'static str)] = &["
    )
    .expect("Could not write to IP delegations output file.");
    for (network, server) in ipv4_delegations {
        writeln!(generated_file, "    (\"{}\", \"{}\"),", network, server)
            .expect("Could not write to IP delegations output file.");
    }
    writeln!(generated_file, "];").expect("Could not write to IP delegations output file.");

    writeln!(generated_file, "").expect("Could not write to IP delegations output file.");
    writeln!(
        generated_file,
        "const IPV6_DELEGATIONS_RAW: &[(&'static str, &'static str)] = &["
    )
    .expect("Could not write to IP delegations output file.");
    for (network, server) in ipv6_delegations {
        writeln!(generated_file, "    (\"{}\", \"{}\"),", network, server)
            .expect("Could not write to IP delegations output file.");
    }
    writeln!(generated_file, "];").expect("Could not write to IP delegations output file.");

    println!("cargo:rerun-if-changed=resources/ip_del_list");
    println!("cargo:rerun-if-changed=resources/ip6_del_list");
    println!("cargo:rerun-if-changed=src/whois/ip.rs");
    Ok(())
}
