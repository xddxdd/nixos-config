use std::env;
use std::path::Path;

mod build {
    pub mod asn;
    pub mod domain;
    pub mod handle;
    pub mod ip;
    // pub mod utils;
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = env::var("OUT_DIR")?;
    let manifest_dir = env::var("CARGO_MANIFEST_DIR")?;

    let out_path = Path::new(&out_dir);
    let manifest_path = Path::new(&manifest_dir);

    build::asn::generate_asn_ranges(manifest_path, out_path)?;
    build::domain::generate_domain_mappings(manifest_path, out_path)?;
    build::handle::generate_nic_handles(manifest_path, out_path)?;
    build::ip::generate_ip_delegations(manifest_path, out_path)?;

    Ok(())
}
