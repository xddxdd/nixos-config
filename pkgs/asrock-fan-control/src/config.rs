use crate::curve::Curve;
use anyhow::{Context, Result, ensure};
use serde::Deserialize;
use std::{collections::HashSet, path::Path, time::Duration};

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Config {
    #[serde(default = "device")]
    pub device: String,
    #[serde(default = "polling")]
    pub polling_seconds: f64,
    #[serde(default = "delay")]
    pub fan_mode_delay_seconds: f64,
    pub fan_slots: Vec<usize>,
    #[serde(default)]
    pub motherboard: Curve,
    pub gpus: Vec<Gpu>,
}

fn device() -> String {
    "/dev/ipmi0".into()
}
fn polling() -> f64 {
    1.0
}
fn delay() -> f64 {
    5.0
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Gpu {
    pub fan_slot: usize,
    pub gpu_uuid: String,
    #[serde(default)]
    pub curve: Curve,
}

impl Config {
    pub fn load(path: &Path) -> Result<Self> {
        let config: Self = toml::from_str(
            &std::fs::read_to_string(path).with_context(|| format!("read {}", path.display()))?,
        )
        .with_context(|| format!("parse {}", path.display()))?;
        config.validate()?;
        Ok(config)
    }

    pub fn validate(&self) -> Result<()> {
        ensure!(
            self.device.starts_with("/dev/") && !self.device.contains('\0'),
            "device must be an absolute /dev/ path"
        );
        for (name, value, minimum, maximum) in [
            ("polling_seconds", self.polling_seconds, 0.1, 60.0),
            (
                "fan_mode_delay_seconds",
                self.fan_mode_delay_seconds,
                0.0,
                10.0,
            ),
        ] {
            ensure!(
                value.is_finite() && (minimum..=maximum).contains(&value),
                "{name} must be between {minimum} and {maximum}"
            );
            Duration::try_from_secs_f64(value).with_context(|| format!("invalid {name}"))?;
        }
        let slots: HashSet<_> = self.fan_slots.iter().copied().collect();
        ensure!(
            !slots.is_empty() && slots.len() == self.fan_slots.len(),
            "fan_slots must be nonempty and unique"
        );
        ensure!(
            slots.iter().all(|slot| *slot < 8),
            "fan slot must be in 0..8"
        );
        ensure!(!self.gpus.is_empty(), "at least one GPU must be configured");
        let mut gpu_slots = HashSet::new();
        let mut uuids = HashSet::new();
        for gpu in &self.gpus {
            ensure!(
                slots.contains(&gpu.fan_slot),
                "GPU fan_slot must be in fan_slots"
            );
            ensure!(gpu_slots.insert(gpu.fan_slot), "duplicate GPU fan_slot");
            let uuid = gpu
                .gpu_uuid
                .strip_prefix("GPU-")
                .context("gpu_uuid must start with GPU-")?;
            ensure!(
                uuid.len() == 36
                    && uuid.bytes().enumerate().all(|(i, b)| {
                        if [8, 13, 18, 23].contains(&i) {
                            b == b'-'
                        } else {
                            b.is_ascii_hexdigit()
                        }
                    }),
                "gpu_uuid must be a full GPU UUID, not an ordinal or prefix"
            );
            ensure!(
                uuids.insert(gpu.gpu_uuid.to_ascii_lowercase()),
                "duplicate GPU UUID"
            );
            gpu.curve.validate().context("GPU curve")?;
            ensure!(
                gpu.curve.min_speed > 0,
                "zero speed selects auto in legacy protocol"
            );
        }
        ensure!(
            slots.len() > gpu_slots.len(),
            "at least one motherboard fan_slot is required"
        );
        self.motherboard.validate().context("motherboard curve")?;
        ensure!(
            self.motherboard.min_speed > 0,
            "zero speed selects auto in legacy protocol"
        );
        Ok(())
    }
}

#[cfg(test)]
pub mod tests {
    use super::*;
    // Synthetic UUIDs and slots, not a hardware mapping.
    pub const CONFIG: &str = r#"
fan_slots = [0, 2, 4]
[[gpus]]
fan_slot = 2
gpu_uuid = "GPU-00000000-0000-0000-0000-000000000001"
[[gpus]]
fan_slot = 4
gpu_uuid = "GPU-00000000-0000-0000-0000-000000000002"
"#;
    #[test]
    fn defaults_and_malformed_config() {
        let config: Config = toml::from_str(CONFIG).unwrap();
        config.validate().unwrap();
        assert_eq!(config.motherboard.speed(85.0), 75);
        for text in [
            "fan_slots = [0, 2, 4]\ngpus = []".into(),
            CONFIG.replace("[0, 2, 4]", "[]"),
            CONFIG.replace("[0, 2, 4]", "[0, 2, 2, 4]"),
            CONFIG.replace("[0, 2, 4]", "[0, 2, 4, 8]"),
            CONFIG.replace("fan_slot = 4", "fan_slot = 2"),
            CONFIG.replace("000000000002", "000000000001"),
            CONFIG.replace("GPU-00000000-0000-0000-0000-000000000001", "0"),
            format!("polling_seconds = nan\n{CONFIG}"),
            format!("polling_seconds = 0\n{CONFIG}"),
            format!("fan_mode_delay_seconds = 11\n{CONFIG}"),
            format!("{CONFIG}\n[gpus.curve]\nmin_speed = 0"),
            format!("{CONFIG}\n[gpus.curve]\nsteps = 0"),
        ] {
            assert!(
                toml::from_str::<Config>(&text).unwrap().validate().is_err(),
                "{text}"
            );
        }
        assert!(toml::from_str::<Config>(&format!("unknown = 1\n{CONFIG}")).is_err());
        assert!(toml::from_str::<Config>(&format!("protocol = \"legacy\"\n{CONFIG}")).is_err());
    }
}
