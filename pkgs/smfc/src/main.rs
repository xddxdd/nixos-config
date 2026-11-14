mod config;
mod ipmi;
mod sdr;

use anyhow::{Context, Result, bail, ensure};
use config::{Config, ZoneState};
use signal_hook::consts::{SIGINT, SIGTERM};
use std::{
    path::PathBuf,
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    },
    time::{Duration, Instant},
};

#[derive(Default, Debug)]
struct Args {
    config: Option<PathBuf>,
    device: Option<String>,
    read_once: bool,
    failsafe: bool,
    help: bool,
}

impl Args {
    fn parse(arguments: impl IntoIterator<Item = String>) -> Result<Self> {
        let mut result = Self::default();
        let mut arguments = arguments.into_iter();
        while let Some(argument) = arguments.next() {
            match argument.as_str() {
                "--config" => {
                    ensure!(result.config.is_none(), "duplicate --config");
                    let path = arguments.next().context("--config requires a path")?;
                    ensure!(
                        !path.starts_with('-'),
                        "--config requires a path, not a flag"
                    );
                    result.config = Some(path.into());
                }
                "--device" => {
                    ensure!(result.device.is_none(), "duplicate --device");
                    let path = arguments.next().context("--device requires a path")?;
                    ensure!(
                        !path.starts_with('-'),
                        "--device requires a path, not a flag"
                    );
                    result.device = Some(path);
                }
                "--read-once" => result.read_once = true,
                "--failsafe" => result.failsafe = true,
                "--help" | "-h" => result.help = true,
                _ => bail!("unknown argument {argument:?}"),
            }
        }
        if !result.help {
            ensure!(
                !(result.read_once && result.failsafe),
                "--read-once and --failsafe are mutually exclusive"
            );
            ensure!(
                result.failsafe || result.config.is_some(),
                "--config PATH is required"
            );
            ensure!(
                !result.failsafe || result.config.is_none(),
                "--failsafe does not use --config; use --device if necessary"
            );
            ensure!(
                result.device.is_none() || result.failsafe,
                "--device is only for --failsafe; otherwise set device in TOML"
            );
        }
        Ok(result)
    }
}

fn open(device: &str) -> Result<ipmi_rs::File> {
    ipmi_rs::File::new(device, Duration::from_secs(2))
        .with_context(|| format!("open IPMI device {device}"))
}

fn daemon(connection: &mut ipmi_rs::File, config: &Config, stop: &AtomicBool) -> Result<()> {
    let mut sensors = ipmi::discover(connection)?;
    let mut zones = [ZoneState::default(), ZoneState::default()];
    let delay = Duration::from_secs_f64(config.fan_mode_delay_seconds);
    let polling = Duration::from_secs_f64(config.polling_seconds);
    let mut ready = false;
    let mut last_log = Instant::now();
    while !stop.load(Ordering::Relaxed) {
        let sample = ipmi::sample(connection, &mut sensors, !ready)?;
        if stop.load(Ordering::Relaxed) {
            break;
        }
        let targets = [
            zones[0].update(&config.cpu, sample.maximum),
            zones[1].update(&config.peripheral, sample.maximum),
        ];
        ipmi::control(connection, targets, delay)?;
        if !ready || last_log.elapsed() >= Duration::from_secs(30) {
            eprintln!(
                "maximum {:?}={:.3} C, {} available sensors, targets cpu={}%, peripheral={}%",
                sample.maximum_name, sample.maximum, sample.count, targets[0], targets[1]
            );
            last_log = Instant::now();
        }
        if !ready {
            sd_notify::notify(false, &[sd_notify::NotifyState::Ready]).context("notify READY")?;
            ready = true;
        }
        // Only successful complete ticks feed the watchdog; a blocked IPMI call must not.
        sd_notify::notify(false, &[sd_notify::NotifyState::Watchdog]).context("notify WATCHDOG")?;
        let sleep_started = Instant::now();
        while !stop.load(Ordering::Relaxed) && sleep_started.elapsed() < polling {
            std::thread::sleep(
                (polling - sleep_started.elapsed().min(polling)).min(Duration::from_millis(100)),
            );
        }
    }
    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse(std::env::args().skip(1))?;
    if args.help {
        println!(
            "smfc --config PATH [--read-once]\nsmfc --failsafe [--device PATH]\n\n--read-once: read temperatures, maximum, targets, mode and duties; no writes or notifications.\n--failsafe: request FULL mode and 100% in both zones, without loading configuration."
        );
        return Ok(());
    }
    if args.failsafe {
        return ipmi::failsafe(
            &mut open(args.device.as_deref().unwrap_or("/dev/ipmi0"))?,
            Duration::from_secs(5),
        );
    }
    let stop = Arc::new(AtomicBool::new(false));
    if !args.read_once {
        signal_hook::flag::register(SIGTERM, Arc::clone(&stop))?;
        signal_hook::flag::register(SIGINT, Arc::clone(&stop))?;
    }
    let config = match Config::load(args.config.as_deref().expect("validated --config")) {
        Ok(config) => config,
        Err(error) => {
            if !args.read_once {
                eprintln!("configuration error: {error:#}; attempting failsafe on /dev/ipmi0");
                match open("/dev/ipmi0").and_then(|mut connection| {
                    ipmi::failsafe(&mut connection, Duration::from_secs(5))
                }) {
                    Ok(()) => {}
                    Err(cleanup) => eprintln!("failsafe failed: {cleanup:#}"),
                }
            }
            return Err(error);
        }
    };
    let mut connection = match open(&config.device) {
        Ok(connection) => connection,
        Err(error) => {
            if !args.read_once {
                eprintln!("IPMI open failed: {error:#}; retrying for failsafe");
                if let Err(cleanup) = open(&config.device).and_then(|mut connection| {
                    ipmi::failsafe(
                        &mut connection,
                        Duration::from_secs_f64(config.fan_mode_delay_seconds),
                    )
                }) {
                    eprintln!("failsafe failed: {cleanup:#}");
                }
            }
            return Err(error);
        }
    };
    if args.read_once {
        let mut sensors = ipmi::discover(&mut connection)?;
        let sample = ipmi::sample(&mut connection, &mut sensors, true)?;
        let mode = ipmi::mode(&mut connection)?;
        let duties = [
            ipmi::duty(&mut connection, 0)?,
            ipmi::duty(&mut connection, 1)?,
        ];
        eprintln!(
            "maximum {:?}={:.3} C, {} available sensors, targets cpu={}%, peripheral={}%, mode={mode}, duty cpu={}%, peripheral={}%",
            sample.maximum_name,
            sample.maximum,
            sample.count,
            config.cpu.speed(sample.maximum),
            config.peripheral.speed(sample.maximum),
            duties[0],
            duties[1]
        );
        return Ok(());
    }
    let result = daemon(&mut connection, &config, &stop);
    if let Err(error) = &result {
        eprintln!("controller stopped: {error:#}");
    }
    let _ = sd_notify::notify(false, &[sd_notify::NotifyState::Stopping]);
    // A timed-out request can leave a late response queued on the old descriptor.
    drop(connection);
    let cleanup = open(&config.device).and_then(|mut connection| {
        ipmi::failsafe(
            &mut connection,
            Duration::from_secs_f64(config.fan_mode_delay_seconds),
        )
    });
    if let Err(error) = &cleanup {
        eprintln!("failsafe failed: {error:#}");
    }
    if stop.load(Ordering::Relaxed) {
        cleanup
    } else {
        result.and(cleanup)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cli_modes_keep_read_only_and_failsafe_separate() {
        let parse = |args: &[&str]| Args::parse(args.iter().map(|arg| (*arg).to_owned()));
        assert!(parse(&["--failsafe"]).unwrap().failsafe);
        assert!(
            parse(&["--config", "fans.toml", "--read-once"])
                .unwrap()
                .read_once
        );
        assert!(parse(&["--failsafe", "--read-once"]).is_err());
        assert!(parse(&[]).is_err());
        assert!(parse(&["--config"]).is_err());
        assert!(parse(&["--config", "--read-once"]).is_err());
        assert!(parse(&["--failsafe", "--config", "missing"]).is_err());
        assert!(parse(&["--config", "fans.toml", "--device", "/dev/ipmi1"]).is_err());
        assert_eq!(
            parse(&["--failsafe", "--device", "/dev/ipmi1"])
                .unwrap()
                .device
                .unwrap(),
            "/dev/ipmi1"
        );
    }
}
