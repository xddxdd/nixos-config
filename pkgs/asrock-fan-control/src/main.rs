mod backend;
mod config;
#[allow(dead_code)]
#[path = "../../smfc/src/config.rs"]
mod curve;
#[allow(dead_code)]
#[path = "../../smfc/src/ipmi.rs"]
mod ipmi;
mod nvml;
mod sdr;
#[path = "../../smfc/src/sdr.rs"]
mod shared_sdr;

use anyhow::{Context, Result, bail, ensure};
use config::Config;
use curve::ZoneState;
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
                "--config" | "--device" => {
                    let value = arguments
                        .next()
                        .with_context(|| format!("{argument} requires a value"))?;
                    ensure!(
                        !value.starts_with('-') && !value.is_empty(),
                        "{argument} requires a value, not a flag"
                    );
                    match argument.as_str() {
                        "--config" => {
                            ensure!(result.config.is_none(), "duplicate --config");
                            result.config = Some(value.into());
                        }
                        _ => {
                            ensure!(result.device.is_none(), "duplicate --device");
                            result.device = Some(value);
                        }
                    }
                }
                "--read-once" => {
                    ensure!(!result.read_once, "duplicate --read-once");
                    result.read_once = true;
                }
                "--failsafe" => {
                    ensure!(!result.failsafe, "duplicate --failsafe");
                    result.failsafe = true;
                }
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
                result
                    .device
                    .as_ref()
                    .is_none_or(|device| device.starts_with("/dev/") && !device.contains('\0')),
                "--device must be an absolute /dev/ path"
            );
        }
        Ok(result)
    }
}

fn open(device: &str) -> Result<ipmi_rs::File> {
    ipmi_rs::File::new(device, Duration::from_secs(2))
        .with_context(|| format!("open IPMI {device}"))
}

fn rescue(config: Option<&Config>, fallback_device: &str) -> Result<()> {
    // Always open a new descriptor: old timed-out responses must not poison cleanup.
    let device = config.map_or(fallback_device, |config| config.device.as_str());
    backend::failsafe(
        &mut open(device)?,
        config.map(|config| config.fan_slots.as_slice()),
        Duration::from_secs_f64(config.map_or(5.0, |config| config.fan_mode_delay_seconds)),
    )
}

fn targets(
    config: &Config,
    maximum: f64,
    readings: &[nvml::Reading],
    zones: &mut [ZoneState],
) -> Result<(Vec<(usize, u8)>, bool)> {
    ensure!(maximum.is_finite(), "non-finite motherboard maximum");
    ensure!(
        readings.len() == config.gpus.len() && zones.len() == config.gpus.len() + 1,
        "missing configured GPU/zone"
    );
    let mut emergency = maximum >= 90.0;
    let motherboard = zones[0].update(&config.motherboard, maximum);
    let mut targets: Vec<_> = config
        .fan_slots
        .iter()
        .map(|slot| (*slot, motherboard))
        .collect();
    for (index, (gpu, reading)) in config.gpus.iter().zip(readings).enumerate() {
        ensure!(reading.uuid == gpu.gpu_uuid, "GPU reading UUID mismatch");
        emergency |= reading.temperature >= 90;
        let target = zones[index + 1].update(&gpu.curve, f64::from(reading.temperature));
        targets
            .iter_mut()
            .find(|(slot, _)| *slot == gpu.fan_slot)
            .context("missing GPU fan slot")?
            .1 = target;
    }
    if emergency {
        for (_, target) in &mut targets {
            *target = 100;
        }
    }
    Ok((targets, emergency))
}

fn print_sample(
    sample: &ipmi::Sample,
    readings: &[nvml::Reading],
    targets: &[(usize, u8)],
    emergency: bool,
) {
    eprintln!(
        "motherboard maximum {:?}={:.3} C, {} available sensors; targets (zero-based slot, percent)={targets:?}, emergency={emergency}",
        sample.maximum_name, sample.maximum, sample.count
    );
    for reading in readings {
        eprintln!(
            "GPU {} {:?}: {} C, slowdown={} C, shutdown={} C",
            reading.uuid, reading.name, reading.temperature, reading.slowdown, reading.shutdown
        );
    }
}

fn run(
    connection: &mut impl ipmi_rs::connection::IpmiConnection,
    config: &Config,
    stop: &AtomicBool,
    read_once: bool,
    mut read_gpu: impl FnMut() -> Result<Vec<nvml::Reading>>,
) -> Result<()> {
    let mut sensors = ipmi::discover(connection)?;
    let mut zones: Vec<_> = (0..=config.gpus.len())
        .map(|_| ZoneState::default())
        .collect();
    let delay = Duration::from_secs_f64(config.fan_mode_delay_seconds);
    let polling = Duration::from_secs_f64(config.polling_seconds);
    let mut ready = false;
    let mut last_log = Instant::now();
    loop {
        if !read_once && stop.load(Ordering::Relaxed) {
            return Ok(());
        }
        let sample = ipmi::sample(connection, &mut sensors, read_once || !ready)?;
        if !read_once && sample.maximum >= 90.0 {
            bail!(
                "motherboard {:?}={:.3} C >=90 C: emergency full-speed shutdown",
                sample.maximum_name,
                sample.maximum
            );
        }
        let readings = read_gpu()?;
        let (targets, emergency) = targets(config, sample.maximum, &readings, &mut zones)?;
        if read_once {
            print_sample(&sample, &readings, &targets, emergency);
            let duties = backend::read(connection)?;
            eprintln!("current 3a/02={duties:?} (0=auto, 1..100=manual percent)");
            return Ok(());
        }
        if emergency {
            print_sample(&sample, &readings, &targets, true);
            bail!("temperature >=90 C: emergency full-speed shutdown");
        }
        if stop.load(Ordering::Relaxed) {
            return Ok(());
        }
        backend::control(connection, &targets, delay)?;
        if !ready || last_log.elapsed() >= Duration::from_secs(30) {
            print_sample(&sample, &readings, &targets, emergency);
            last_log = Instant::now();
        }
        if !ready {
            sd_notify::notify(false, &[sd_notify::NotifyState::Ready]).context("notify READY")?;
            ready = true;
        }
        // Feed only after a complete successful sample and control tick.
        sd_notify::notify(false, &[sd_notify::NotifyState::Watchdog]).context("notify WATCHDOG")?;
        let started = Instant::now();
        while !stop.load(Ordering::Relaxed) && started.elapsed() < polling {
            std::thread::sleep(
                polling
                    .saturating_sub(started.elapsed())
                    .min(Duration::from_millis(100)),
            );
        }
    }
}

fn main() -> Result<()> {
    let args = Args::parse(std::env::args().skip(1))?;
    if args.help {
        println!(
            "asrock-fan-control --config PATH [--read-once] [--device PATH]\nasrock-fan-control --failsafe [--config PATH] [--device PATH]\n\nASRock EPYCD8: eight-byte 3a/01 control and 3a/02 readback.\n--device supplies configuration-error recovery and must match valid TOML.\n--read-once: ZERO writes and notifications, including on errors.\n--failsafe: no GPU loading; configured slots 100%, or all slots 100% without valid config."
        );
        return Ok(());
    }
    let fallback_device = args.device.as_deref().unwrap_or("/dev/ipmi0");
    let stop = Arc::new(AtomicBool::new(false));
    if !args.read_once {
        signal_hook::flag::register(SIGTERM, Arc::clone(&stop))?;
        signal_hook::flag::register(SIGINT, Arc::clone(&stop))?;
    }
    let loaded = args
        .config
        .as_deref()
        .map(|path| {
            Config::load(path).and_then(|config| {
                ensure!(
                    args.device
                        .as_ref()
                        .is_none_or(|device| *device == config.device),
                    "--device disagrees with TOML device"
                );
                Ok(config)
            })
        })
        .transpose();
    let config = match loaded {
        Ok(config) => config,
        Err(error) => {
            eprintln!("configuration error: {error:#}");
            if !args.read_once {
                let cleanup = rescue(None, fallback_device);
                if let Err(cleanup) = &cleanup {
                    eprintln!("failsafe failed: {cleanup:#}");
                }
                if args.failsafe {
                    return cleanup;
                }
            }
            return Err(error);
        }
    };
    if args.failsafe {
        return rescue(config.as_ref(), fallback_device);
    }
    let config = config.context("missing configuration")?;
    let result = open(&config.device).and_then(|mut connection| {
        let reader =
            nvml::Reader::start(config.gpus.iter().map(|gpu| gpu.gpu_uuid.clone()).collect())?;
        run(&mut connection, &config, &stop, args.read_once, || {
            reader.read()
        })
    });
    if args.read_once {
        return result;
    }
    if let Err(error) = &result {
        eprintln!("controller stopped: {error:#}");
    }
    let _ = sd_notify::notify(false, &[sd_notify::NotifyState::Stopping]);
    let cleanup = rescue(Some(&config), fallback_device);
    if let Err(error) = &cleanup {
        eprintln!("failsafe failed: {error:#}");
    }
    result.and(cleanup)
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn cli_modes_separate_read_only_and_failsafe() {
        let parse = |args: &[&str]| Args::parse(args.iter().map(|arg| (*arg).into()));
        for args in [
            vec![],
            vec!["--read-once", "--failsafe"],
            vec!["--config"],
            vec!["--config", "--read-once"],
            vec!["--device", "relative", "--failsafe"],
            vec!["--config", "a", "--config", "b"],
            vec!["--failsafe", "--failsafe"],
            vec!["--protocol", "legacy", "--failsafe"],
        ] {
            assert!(parse(&args).is_err(), "{args:?}");
        }
        assert!(parse(&["--failsafe"]).unwrap().failsafe);
        assert!(parse(&["--config", "fans.toml"]).unwrap().config.is_some());
        assert!(
            parse(&["--config", "fans.toml", "--read-once"])
                .unwrap()
                .read_once
        );
        assert!(
            parse(&["--failsafe", "--config", "fans.toml"])
                .unwrap()
                .failsafe
        );
        assert_eq!(
            parse(&["--failsafe", "--device", "/dev/ipmi1"])
                .unwrap()
                .device
                .as_deref(),
            Some("/dev/ipmi1")
        );
    }
    use ipmi_rs::connection::{IpmiConnection, Message, Request, Response};
    use std::{collections::VecDeque, io};

    // Synthetic SDR/reading fixtures; the mock rejects every unlisted command.
    struct ReadOnly(VecDeque<(u8, u8, Vec<u8>, Vec<u8>)>);
    impl ReadOnly {
        fn temperature(temperature: u8) -> Self {
            let info = vec![0, 0x51, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            let mut record = vec![0, 0xff, 0xff];
            record.extend(sdr::tests::record(1, "CPU Temp"));
            Self(VecDeque::from([
                (0x0a, 0x20, vec![], info.clone()),
                (0x0a, 0x23, vec![0, 0, 0, 0, 0, 0xff], record),
                (0x0a, 0x20, vec![], info),
                (4, 0x2d, vec![1], vec![0, temperature, 0x40]),
            ]))
        }
    }
    impl IpmiConnection for ReadOnly {
        type SendError = io::Error;
        type RecvError = io::Error;
        type Error = io::Error;
        fn send(&mut self, _: &mut Request) -> io::Result<()> {
            panic!("unexpected send")
        }
        fn recv(&mut self) -> io::Result<Response> {
            panic!("unexpected recv")
        }
        fn send_recv(&mut self, request: &mut Request) -> io::Result<Response> {
            let (netfn, cmd, data, reply) = self.0.pop_front().expect("unexpected command/write");
            assert_eq!(
                (request.netfn_raw(), request.cmd(), request.data()),
                (netfn, cmd, data.as_slice())
            );
            Ok(Response::new(Message::new_raw(netfn | 1, cmd, reply), 0).unwrap())
        }
    }

    #[test]
    fn motherboard_emergency_skips_gpu_getter_but_read_once_stays_read_only() {
        let config: Config = toml::from_str(config::tests::CONFIG).unwrap();
        for read_once in [false, true] {
            let mut fake = ReadOnly::temperature(90);
            let mut gpu_called = false;
            let error = run(
                &mut fake,
                &config,
                &AtomicBool::new(false),
                read_once,
                || {
                    assert!(read_once, "GPU getter called despite motherboard emergency");
                    gpu_called = true;
                    bail!("synthetic GPU getter error");
                },
            )
            .unwrap_err();
            assert_eq!(gpu_called, read_once);
            assert!(error.to_string().contains(if read_once {
                "synthetic GPU getter error"
            } else {
                "motherboard"
            }));
            assert!(fake.0.is_empty());
        }
    }

    #[test]
    fn read_once_success_emergency_and_gpu_error_never_write() {
        let config: Config = toml::from_str(config::tests::CONFIG).unwrap();
        for scenario in 0..3 {
            let mut fake = ReadOnly::temperature(70);
            if scenario != 2 {
                // Captured baseline: eight all-auto bytes after cc=0.
                fake.0.push_back((0x3a, 2, vec![], vec![0; 9]));
            }
            let result = run(&mut fake, &config, &AtomicBool::new(false), true, || {
                if scenario == 2 {
                    bail!("synthetic GPU disappearance");
                }
                Ok(config
                    .gpus
                    .iter()
                    .map(|gpu| nvml::Reading {
                        uuid: gpu.gpu_uuid.clone(),
                        name: "Tesla P40".into(),
                        temperature: if scenario == 1 { 90 } else { 70 },
                        slowdown: 92,
                        shutdown: 95,
                    })
                    .collect())
            });
            assert_eq!(result.is_err(), scenario == 2);
            assert!(fake.0.is_empty());
        }
    }

    #[test]
    fn independent_gpu_targets_shared_curve_reference_and_emergency() {
        let config: Config = toml::from_str(config::tests::CONFIG).unwrap();
        config.validate().unwrap();
        let mut readings: Vec<_> = config
            .gpus
            .iter()
            .map(|gpu| nvml::Reading {
                uuid: gpu.gpu_uuid.clone(),
                name: "Tesla P40".into(),
                temperature: 65,
                slowdown: 92,
                shutdown: 95,
            })
            .collect();
        readings[1].temperature = 85;
        let mut zones = [
            ZoneState::default(),
            ZoneState::default(),
            ZoneState::default(),
        ];
        assert_eq!(
            targets(&config, 70., &readings, &mut zones).unwrap(),
            (vec![(0, 41), (2, 30), (4, 75)], false)
        );
        readings[0].temperature = 90;
        assert_eq!(
            targets(&config, 70., &readings, &mut zones).unwrap(),
            (vec![(0, 100), (2, 100), (4, 100)], true)
        );
        readings[0].temperature = 65;
        assert!(targets(&config, 90., &readings, &mut zones).unwrap().1);
        assert!(targets(&config, 70., &readings[..1], &mut zones).is_err());
        readings[0].uuid = "GPU-wrong".into();
        assert!(targets(&config, 70., &readings, &mut zones).is_err());
    }
}
