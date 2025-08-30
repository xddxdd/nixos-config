use std::fs;
use std::io::Write;
use std::path::Path;

fn normalize_asn_build_script(asn_str: &str) -> Option<u32> {
    if asn_str.contains('.') {
        let parts: Vec<&str> = asn_str.split('.').collect();
        if parts.len() == 2 {
            let h_part = parts[0].parse::<u32>().ok()?;
            let l_part = parts[1].parse::<u32>().ok()?;
            Some(h_part * 65536 + l_part)
        } else {
            None
        }
    } else {
        asn_str.parse::<u32>().ok()
    }
}

pub fn generate_asn_ranges(
    manifest_dir: &Path,
    out_dir: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    let dest_path = out_dir.join("generated_asn_ranges.rs");
    let mut generated_file =
        fs::File::create(&dest_path).expect("Could not create output file for ASN ranges.");

    let as_del_list_path = manifest_dir.join("resources/as_del_list");
    let content = fs::read_to_string(&as_del_list_path).expect("Could not read as_del_list file.");

    let mut ranges: Vec<(u32, u32, String)> = Vec::new();
    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }

        let parts: Vec<&str> = line.split('\t').collect();
        if parts.len() == 3 {
            if let (Some(start_asn), Some(end_asn)) = (
                normalize_asn_build_script(parts[0]),
                normalize_asn_build_script(parts[1]),
            ) {
                ranges.push((start_asn, end_asn, parts[2].to_string()));
            }
        }
    }

    writeln!(generated_file, "#[allow(dead_code)]").expect("Could not write to ASN output file.");
    writeln!(generated_file, "#[allow(clippy::unreadable_literal)]")
        .expect("Could not write to ASN output file.");
    writeln!(generated_file, "").expect("Could not write to ASN output file.");
    writeln!(generated_file, "const AS_RANGES: &[AsRange] = &[")
        .expect("Could not write to ASN output file.");
    for (start, end, server) in ranges {
        writeln!(
            generated_file,
            "    AsRange {{ start: {}, end: {}, server: \"{}\" }},",
            start, end, server
        )
        .expect("Could not write to ASN output file.");
    }
    writeln!(generated_file, "];").expect("Could not write to ASN output file.");

    println!("cargo:rerun-if-changed=resources/as_del_list");
    println!("cargo:rerun-if-changed=src/whois/asn.rs");
    Ok(())
}
