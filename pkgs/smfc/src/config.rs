use anyhow::{Context, Result, ensure};
use serde::Deserialize;
use std::{path::Path, time::Duration};

#[derive(Debug, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Config {
    pub device: String,
    pub polling_seconds: f64,
    pub fan_mode_delay_seconds: f64,
    pub cpu: Curve,
    pub peripheral: Curve,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            device: "/dev/ipmi0".into(),
            polling_seconds: 1.0,
            fan_mode_delay_seconds: 5.0,
            cpu: Curve::default(),
            peripheral: Curve::default(),
        }
    }
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
        ensure!(!self.device.is_empty(), "device must not be empty");
        for (name, seconds, positive) in [
            ("polling_seconds", self.polling_seconds, true),
            ("fan_mode_delay_seconds", self.fan_mode_delay_seconds, false),
        ] {
            ensure!(
                seconds.is_finite() && seconds >= 0.0 && (!positive || seconds > 0.0),
                "invalid {name}"
            );
            Duration::try_from_secs_f64(seconds).with_context(|| format!("invalid {name}"))?;
        }
        self.cpu.validate().context("cpu")?;
        self.peripheral.validate().context("peripheral")
    }
}

#[derive(Debug, Clone, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Curve {
    pub min_speed: u8,
    pub max_speed: u8,
    pub min_temp: f64,
    pub max_temp: f64,
    pub sensitivity: f64,
    pub steps: u32,
}

impl Default for Curve {
    fn default() -> Self {
        Self {
            min_speed: 30,
            max_speed: 75,
            min_temp: 65.0,
            max_temp: 85.0,
            sensitivity: 1.0,
            steps: 20,
        }
    }
}

impl Curve {
    pub fn validate(&self) -> Result<()> {
        ensure!(
            self.min_speed <= self.max_speed && self.max_speed <= 100,
            "speeds must satisfy 0 <= min_speed <= max_speed <= 100"
        );
        ensure!(
            self.min_temp.is_finite()
                && self.max_temp.is_finite()
                && self.min_temp < self.max_temp
                && (self.max_temp - self.min_temp).is_finite(),
            "temperatures must be finite and min_temp < max_temp"
        );
        ensure!(
            self.sensitivity.is_finite() && self.sensitivity > 0.0,
            "sensitivity must be positive and finite"
        );
        ensure!(self.steps > 0, "steps must be positive");
        ensure!(
            (self.max_temp - self.min_temp) / f64::from(self.steps) > 0.0,
            "temperature step underflow"
        );
        Ok(())
    }

    pub fn speed(&self, temperature: f64) -> u8 {
        if temperature <= self.min_temp {
            self.min_speed
        } else if temperature >= self.max_temp {
            self.max_speed
        } else {
            // Match smfc.py: round the gain and speed delta separately, ties to even.
            let temp_step = (self.max_temp - self.min_temp) / f64::from(self.steps);
            let speed_step = f64::from(self.max_speed - self.min_speed) / f64::from(self.steps);
            let gain = ((temperature - self.min_temp) / temp_step).round_ties_even();
            self.min_speed + (gain * speed_step).round_ties_even() as u8
        }
    }
}

#[derive(Default)]
pub struct ZoneState {
    last_temperature: Option<f64>,
    target: Option<u8>,
}

impl ZoneState {
    pub fn update(&mut self, curve: &Curve, temperature: f64) -> u8 {
        if self.last_temperature.is_none_or(|last| {
            (temperature - last).abs() >= curve.sensitivity
                || temperature <= curve.min_temp
                || temperature >= curve.max_temp
        }) {
            self.last_temperature = Some(temperature);
            self.target = Some(curve.speed(temperature));
        }
        self.target.expect("first sample always sets a target")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn python_curve_reference_endpoints_steps_and_ties() {
        // Obtained by executing the supplied FanController.run(), not its mapping logger.
        let temperatures = [
            64., 65., 65.5, 66., 66.5, 67., 67.5, 68., 69., 70., 71., 72., 73., 74., 75., 76., 77.,
            78., 79., 80., 81., 82., 83., 84., 84.5, 85., 86.,
        ];
        let expected = [
            30, 30, 30, 32, 34, 34, 34, 37, 39, 41, 44, 46, 48, 50, 52, 55, 57, 59, 62, 64, 66, 68,
            70, 73, 75, 75, 75,
        ];
        for (temperature, speed) in temperatures.into_iter().zip(expected) {
            assert_eq!(Curve::default().speed(temperature), speed);
            let odd_minimum = Curve {
                min_speed: 31,
                max_speed: 76,
                ..Curve::default()
            };
            assert_eq!(odd_minimum.speed(temperature), speed + 1);
        }
    }

    #[test]
    fn sensitivity_is_absolute_from_last_accepted_sample() {
        let curve = Curve::default();
        let mut zone = ZoneState::default();
        assert_eq!(zone.update(&curve, 70.), 41);
        assert_eq!(zone.update(&curve, 70.6), 41);
        assert_eq!(zone.update(&curve, 71.), 44);
        assert_eq!(zone.update(&curve, 70.2), 44);
        assert_eq!(zone.update(&curve, 70.), 41);
    }

    #[test]
    fn boundaries_override_sensitivity_and_zones_are_independent() {
        let curve = Curve::default();
        let mut cpu = ZoneState::default();
        let mut peripheral = ZoneState::default();
        assert_eq!(cpu.update(&curve, 65.6), 32);
        assert_eq!(cpu.update(&curve, 65.), 30);
        assert_eq!(peripheral.update(&curve, 84.4), 73);
        assert_eq!(peripheral.update(&curve, 85.), 75);
        assert_eq!(cpu.update(&curve, 65.2), 30);
        assert_eq!(peripheral.update(&curve, 84.6), 75);
    }

    #[test]
    fn config_defaults_and_invalid_values() {
        let config: Config = toml::from_str("[cpu]\n[peripheral]\n").unwrap();
        config.validate().unwrap();
        assert_eq!(config.cpu.steps, 20);
        assert_eq!(config.device, "/dev/ipmi0");
        assert!(toml::from_str::<Config>("unknown = 1").is_err());
        for source in [
            "polling_seconds = 0",
            "fan_mode_delay_seconds = -1",
            "[cpu]\nsteps = 0",
            "[cpu]\nmin_speed = 101",
            "[cpu]\nmax_temp = 65",
            "[cpu]\nsensitivity = nan",
        ] {
            assert!(
                toml::from_str::<Config>(source)
                    .unwrap()
                    .validate()
                    .is_err(),
                "{source}"
            );
        }
    }
}
