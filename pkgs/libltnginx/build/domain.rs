use std::fs;
use std::io::Write;
use std::path::Path;

pub fn generate_domain_mappings(
    manifest_dir: &Path,
    out_dir: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let dest_path = out_dir.join("generated_domain_mappings.rs");
    let mut generated_file =
        fs::File::create(&dest_path).expect("Could not create output file for domain mappings.");

    let tld_server_list_path = manifest_dir.join("resources/tld_serv_list");
    let tld_server_content =
        fs::read_to_string(&tld_server_list_path).expect("Could not read tld_serv_list file.");

    let new_gtld_list_path = manifest_dir.join("resources/new_gtlds_list");
    let new_gtld_content =
        fs::read_to_string(&new_gtld_list_path).expect("Could not read new_gtlds_list file.");

    let mut mapping: Vec<(String, String)> = tld_server_content
        .lines()
        .filter(|line| !line.trim_start().starts_with('#') && !line.trim().is_empty())
        .filter_map(|line| {
            let line_without_comment = line.split('#').next().unwrap_or("").trim();
            if line_without_comment.is_empty() {
                return None;
            }
            let parts: Vec<&str> = line_without_comment.split_whitespace().collect();
            if parts.len() >= 2 {
                let suffix = parts[0].to_ascii_lowercase();
                let server_candidate = parts[1];
                if ["RECURSIVE", "VERISIGN"].contains(&parts[1]) {
                    return Some((suffix, parts.last().unwrap().to_string()));
                }
                if !["NONE", "WEB", "ARPA", "IP6"].contains(&server_candidate) {
                    return Some((suffix, server_candidate.to_string()));
                }
            }
            None
        })
        .collect();

    let mut new_gtld_mapping: Vec<(String, String)> = new_gtld_content
        .lines()
        .filter(|line| !line.trim_start().starts_with('#') && !line.trim().is_empty())
        .map(|line| {
            (
                format!(".{}", line.to_string()),
                format!("whois.nic.{}", line),
            )
        })
        .collect();
    mapping.append(&mut new_gtld_mapping);

    mapping.sort_by(|a, b| b.0.len().cmp(&a.0.len()));

    writeln!(generated_file, "#[allow(dead_code)]")
        .expect("Could not write to Domain output file.");
    writeln!(generated_file, "#[allow(clippy::unreadable_literal)]")
        .expect("Could not write to Domain output file.");
    writeln!(generated_file, "").expect("Could not write to Domain output file.");
    writeln!(
        generated_file,
        "const TLD_SERVER_MAPPING: &[(&'static str, &'static str)] = &["
    )
    .expect("Could not write to Domain output file.");
    for (suffix, server) in mapping {
        writeln!(generated_file, "    (\"{}\", \"{}\"),", suffix, server)
            .expect("Could not write to Domain output file.");
    }
    writeln!(generated_file, "];").expect("Could not write to Domain output file.");

    println!("cargo:rerun-if-changed=resources/tld_serv_list");
    println!("cargo:rerun-if-changed=resources/new_gtlds_list");
    println!("cargo:rerun-if-changed=src/whois/domain.rs");
    Ok(())
}
