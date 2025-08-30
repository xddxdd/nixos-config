use std::fs;
use std::io::Write;
use std::path::Path;

pub fn generate_nic_handles(
    manifest_dir: &Path,
    out_dir: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let dest_path = out_dir.join("generated_handle_mappings.rs");
    let mut generated_file = fs::File::create(&dest_path)
        .expect("Could not create output file for NIC handle mappings.");

    let nic_handles_list_path = manifest_dir.join("resources/nic_handles_list");
    let content =
        fs::read_to_string(&nic_handles_list_path).expect("Could not read nic_handles_list file.");

    let mut mapping: Vec<(String, String)> = Vec::new();
    for line in content.lines() {
        if let Some(pos) = line.find('\t') {
            let suffix = line[..pos].trim_start_matches('-').to_lowercase();
            let server = line[pos + 1..].trim().to_string();
            mapping.push((suffix, server));
        }
    }

    writeln!(generated_file, "#[allow(dead_code)]")
        .expect("Could not write to NIC handles output file.");
    writeln!(generated_file, "#[allow(clippy::unreadable_literal)]")
        .expect("Could not write to NIC handles output file.");
    writeln!(generated_file, "").expect("Could not write to NIC handles output file.");
    writeln!(
        generated_file,
        "const NIC_HANDLES_MAP: &[(&'static str, &'static str)] = &["
    )
    .expect("Could not write to NIC handles output file.");
    for (suffix, server) in mapping {
        writeln!(generated_file, "    (\"{}\", \"{}\"),", suffix, server)
            .expect("Could not write to NIC handles output file.");
    }
    writeln!(generated_file, "];").expect("Could not write to NIC handles output file.");

    println!("cargo:rerun-if-changed=resources/nic_handles_list");
    println!("cargo:rerun-if-changed=src/whois/handle.rs");
    Ok(())
}
