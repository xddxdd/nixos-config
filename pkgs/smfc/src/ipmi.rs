use crate::sdr::{Sensor, parse_record};
use anyhow::{Context, Result, anyhow, ensure};
use ipmi_rs::connection::{
    IpmiConnection, LogicalUnit, Message, Request, RequestTargetAddress, Response,
};
use std::{collections::HashSet, time::Duration};

fn exchange(
    connection: &mut impl IpmiConnection,
    netfn: u8,
    command: u8,
    data: &[u8],
    lun: u8,
) -> Result<Response> {
    let mut request = Request::new(
        Message::new_raw(netfn, command, data.to_vec()),
        RequestTargetAddress::Bmc(LogicalUnit::from_low_bits(lun)),
    );
    // Do not use Ipmi::send_recv: its OEM netfn equality check rejects real responses.
    let response = connection
        .send_recv(&mut request)
        .map_err(|error| anyhow!("IPMI {netfn:02x}/{command:02x}: {error:?}"))?;
    ensure!(
        response.netfn_raw() == netfn | 1 && response.cmd() == command,
        "unexpected IPMI response {:02x}/{:02x} for {netfn:02x}/{command:02x}",
        response.netfn_raw(),
        response.cmd()
    );
    Ok(response)
}

pub fn raw(
    connection: &mut impl IpmiConnection,
    netfn: u8,
    command: u8,
    data: &[u8],
    lun: u8,
) -> Result<Vec<u8>> {
    let response = exchange(connection, netfn, command, data, lun)?;
    ensure!(
        response.cc() == 0,
        "IPMI {netfn:02x}/{command:02x}: completion code {:#04x}",
        response.cc()
    );
    Ok(response.data().to_vec())
}

fn repository_info(connection: &mut impl IpmiConnection) -> Result<Vec<u8>> {
    let info = raw(connection, 0x0a, 0x20, &[], 0)?;
    ensure!(
        info.len() == 14 && info[0] == 0x51,
        "invalid SDR repository info"
    );
    Ok(info)
}

pub fn discover(connection: &mut impl IpmiConnection) -> Result<Vec<Sensor>> {
    let before = repository_info(connection)?;
    let count = usize::from(u16::from_le_bytes([before[1], before[2]]));
    ensure!(count > 0, "empty SDR repository");
    let mut requested = HashSet::new();
    let mut records = HashSet::new();
    let mut keys = HashSet::new();
    let mut sensors = Vec::new();
    let mut id = 0u16;
    loop {
        ensure!(requested.insert(id), "cycle in SDR repository at {id:04x}");
        let [low, high] = id.to_le_bytes();
        let data = raw(connection, 0x0a, 0x23, &[0, 0, low, high, 0, 0xff], 0)
            .with_context(|| format!("read SDR {id:04x}"))?;
        ensure!(data.len() >= 7, "truncated Get SDR response");
        let next = u16::from_le_bytes([data[0], data[1]]);
        let (actual_id, sensor) =
            parse_record(&data[2..], id).with_context(|| format!("parse SDR {id:04x}"))?;
        ensure!(
            records.insert(actual_id),
            "duplicate SDR record {actual_id:04x}"
        );
        ensure!(
            records.len() <= count,
            "SDR repository exceeds advertised count {count}"
        );
        if let Some(sensor) = sensor {
            ensure!(
                keys.insert(sensor.key()),
                "duplicate temperature sensor key {:?}",
                sensor.key()
            );
            sensors.push(sensor);
        }
        if next == 0xffff {
            break;
        }
        ensure!(
            next != actual_id && !records.contains(&next),
            "cycle in SDR repository at {next:04x}"
        );
        id = next;
    }
    ensure!(
        records.len() == count,
        "partial SDR repository: got {} of {count} records",
        records.len()
    );
    let after = repository_info(connection)?;
    ensure!(
        before[1..3] == after[1..3] && before[5..13] == after[5..13],
        "SDR repository changed during enumeration"
    );
    ensure!(
        sensors.iter().any(|s| !s.excluded),
        "no non-GPU temperature sensors in SDR repository"
    );
    Ok(sensors)
}

pub struct Sample {
    pub maximum: f64,
    pub maximum_name: String,
    pub count: usize,
}

pub fn sample(
    connection: &mut impl IpmiConnection,
    sensors: &mut [Sensor],
    log_each: bool,
) -> Result<Sample> {
    let mut result = Sample {
        maximum: f64::NEG_INFINITY,
        maximum_name: String::new(),
        count: 0,
    };
    for sensor in sensors {
        if sensor.excluded {
            if log_each {
                eprintln!("sensor {:?}: excluded GPU", sensor.name);
            }
            continue;
        }
        let (_, _, lun, number) = sensor.key();
        let response = exchange(connection, 4, 0x2d, &[number], lun)
            .with_context(|| format!("read sensor {:?}", sensor.name))?;
        ensure!(
            matches!(response.cc(), 0 | 0xcb),
            "read sensor {:?}: IPMI 04/2d: completion code {:#04x}",
            sensor.name,
            response.cc()
        );
        // An absent optional sensor (e.g. an empty M.2 slot) can return cc=cb.
        // Reuse the normal unavailable path so disappearance remains fatal.
        let data = if response.cc() == 0xcb {
            &[0, 0x20]
        } else {
            response.data()
        };
        if let Some(temperature) = sensor.reading(data)? {
            if log_each {
                eprintln!("sensor {:?}: {temperature:.3} C", sensor.name);
            }
            result.count += 1;
            if temperature > result.maximum {
                result.maximum = temperature;
                result.maximum_name.clone_from(&sensor.name);
            }
        } else if log_each {
            eprintln!(
                "sensor {:?}: unavailable/scanning disabled (skipped)",
                sensor.name
            );
        }
    }
    ensure!(result.count > 0, "no available non-GPU temperature sensors");
    Ok(result)
}

pub fn mode(connection: &mut impl IpmiConnection) -> Result<u8> {
    let data = raw(connection, 0x30, 0x45, &[0], 0)?;
    ensure!(data.len() == 1, "invalid fan mode response length");
    Ok(data[0])
}

pub fn duty(connection: &mut impl IpmiConnection, zone: u8) -> Result<u8> {
    let data = raw(connection, 0x30, 0x70, &[0x66, 0, zone], 0)?;
    ensure!(
        data.len() == 1 && data[0] <= 100,
        "invalid fan duty response for zone {zone}"
    );
    Ok(data[0])
}

fn set_full(connection: &mut impl IpmiConnection) -> Result<()> {
    ensure!(
        raw(connection, 0x30, 0x45, &[1, 1], 0)?.is_empty(),
        "unexpected Set Fan Mode response data"
    );
    Ok(())
}

fn set_duty(connection: &mut impl IpmiConnection, zone: u8, target: u8) -> Result<()> {
    ensure!(
        raw(connection, 0x30, 0x70, &[0x66, 1, zone, target], 0)?.is_empty(),
        "unexpected Set Fan Duty response data"
    );
    ensure!(
        duty(connection, zone)? == target,
        "fan duty verification failed for zone {zone}: expected {target}%"
    );
    Ok(())
}

pub fn control(
    connection: &mut impl IpmiConnection,
    targets: [u8; 2],
    delay: Duration,
) -> Result<()> {
    let current_mode = mode(connection)?;
    let current_duty = [duty(connection, 0)?, duty(connection, 1)?];
    let reset = current_mode != 1;
    if reset {
        eprintln!("fan mode {current_mode} -> FULL; settling for {delay:?}");
        set_full(connection)?;
        std::thread::sleep(delay);
        ensure!(mode(connection)? == 1, "FULL fan mode verification failed");
    }
    if reset || current_duty != targets {
        for (zone, target) in targets.into_iter().enumerate() {
            set_duty(connection, zone as u8, target)?;
        }
    }
    Ok(())
}

pub fn failsafe(connection: &mut impl IpmiConnection, delay: Duration) -> Result<()> {
    let mut errors = Vec::new();
    // Each operation is independent: a failed mode/zone command must not suppress the others.
    if let Err(error) = set_full(connection) {
        errors.push(format!("FULL mode: {error:#}"));
    }
    std::thread::sleep(delay);
    for zone in 0..2 {
        if let Err(error) = set_duty(connection, zone, 100) {
            errors.push(format!("zone {zone}: {error:#}"));
        }
    }
    match mode(connection) {
        Ok(1) => {}
        Ok(value) => errors.push(format!("FULL mode verification returned {value}")),
        Err(error) => errors.push(format!("FULL mode verification: {error:#}")),
    }
    ensure!(
        errors.is_empty(),
        "failsafe incomplete: {}",
        errors.join("; ")
    );
    eprintln!("failsafe: FULL mode, both zones 100%");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::sdr::tests::record;
    use ipmi_rs::connection::Response;
    use std::{collections::VecDeque, io};

    struct Exchange {
        netfn: u8,
        cmd: u8,
        data: Vec<u8>,
        reply: Result<Response, io::Error>,
    }
    #[derive(Default)]
    struct Mock {
        exchanges: VecDeque<Exchange>,
    }

    impl Mock {
        fn expect(&mut self, netfn: u8, cmd: u8, data: &[u8], reply: &[u8]) {
            self.exchanges.push_back(Exchange {
                netfn,
                cmd,
                data: data.to_vec(),
                reply: Ok(
                    Response::new(Message::new_raw(netfn | 1, cmd, reply.to_vec()), 0).unwrap(),
                ),
            });
        }
        fn done(&self) {
            assert!(
                self.exchanges.is_empty(),
                "{} unconsumed exchanges",
                self.exchanges.len()
            );
        }
        fn info(&mut self, count: u16) {
            let [low, high] = count.to_le_bytes();
            self.expect(
                0x0a,
                0x20,
                &[],
                &[0, 0x51, low, high, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            );
        }
        fn sdr(&mut self, requested: u16, next: u16, record: &[u8]) {
            let [lo, hi] = requested.to_le_bytes();
            let [nlo, nhi] = next.to_le_bytes();
            let mut response = vec![0, nlo, nhi];
            response.extend_from_slice(record);
            self.expect(0x0a, 0x23, &[0, 0, lo, hi, 0, 0xff], &response);
        }
        fn readback(&mut self, mode: u8, duties: [u8; 2]) {
            self.expect(0x30, 0x45, &[0], &[0, mode]);
            for zone in 0..2 {
                self.expect(0x30, 0x70, &[0x66, 0, zone], &[0, duties[zone as usize]]);
            }
        }
        fn write(&mut self, zone: u8, target: u8) {
            self.expect(0x30, 0x70, &[0x66, 1, zone, target], &[0]);
            self.expect(0x30, 0x70, &[0x66, 0, zone], &[0, target]);
        }
    }
    impl IpmiConnection for Mock {
        type SendError = io::Error;
        type RecvError = io::Error;
        type Error = io::Error;
        fn send(&mut self, _: &mut Request) -> io::Result<()> {
            panic!("use direct send_recv")
        }
        fn recv(&mut self) -> io::Result<Response> {
            panic!("use direct send_recv")
        }
        fn send_recv(&mut self, request: &mut Request) -> io::Result<Response> {
            let exchange = self.exchanges.pop_front().expect("unexpected IPMI command");
            assert_eq!(request.netfn_raw(), exchange.netfn);
            assert_eq!(request.cmd(), exchange.cmd);
            assert_eq!(request.data(), exchange.data);
            assert!(matches!(request.target(), RequestTargetAddress::Bmc(_)));
            exchange.reply
        }
    }

    #[test]
    fn raw_oem_payload_response_validation() {
        let mut mock = Mock::default();
        mock.expect(0x30, 0x45, &[0], &[0, 1]);
        assert_eq!(mode(&mut mock).unwrap(), 1);
        for (netfn, cmd, cc) in [
            (0x30, 0x45, 0),
            (0x33, 0x45, 0),
            (0x31, 0x70, 0),
            (0x31, 0x45, 0xc1),
        ] {
            mock.expect(0x30, 0x45, &[0], &[0, 1]);
            mock.exchanges.back_mut().unwrap().reply =
                Ok(Response::new(Message::new_raw(netfn, cmd, vec![cc, 1]), 0).unwrap());
            assert!(mode(&mut mock).is_err());
        }
        mock.done();
    }

    #[test]
    fn complete_discovery_and_read_only_sample() {
        let mut mock = Mock::default();
        mock.info(2);
        mock.sdr(0, 9, &record(5, "CPU Temp"));
        mock.sdr(9, 0xffff, &record(9, "GPU1 Temp"));
        mock.info(2);
        let mut sensors = discover(&mut mock).unwrap();
        mock.expect(4, 0x2d, &[5], &[0, 70, 0x40]);
        let result = sample(&mut mock, &mut sensors, true).unwrap();
        assert_eq!(result.maximum, 70.);
        assert_eq!(result.count, 1);
        assert_eq!(result.maximum_name, "CPU Temp");
        mock.readback(2, [40, 50]);
        assert_eq!(mode(&mut mock).unwrap(), 2);
        assert_eq!(duty(&mut mock, 0).unwrap(), 40);
        assert_eq!(duty(&mut mock, 1).unwrap(), 50);
        mock.done();
    }

    #[test]
    fn discovery_empty_partial_cycle_duplicate_and_transport_error() {
        let mut mock = Mock::default();
        mock.info(0);
        assert!(discover(&mut mock).is_err());
        mock.done();
        let mut mock = Mock::default();
        mock.info(2);
        mock.sdr(0, 0xffff, &record(1, "CPU Temp"));
        assert!(discover(&mut mock).is_err());
        mock.done();
        let mut mock = Mock::default();
        mock.info(2);
        mock.sdr(0, 1, &record(1, "CPU Temp"));
        assert!(discover(&mut mock).is_err());
        mock.done();
        let mut mock = Mock::default();
        mock.info(2);
        mock.sdr(0, 2, &record(1, "CPU Temp"));
        let mut duplicate = record(2, "Other Temp");
        duplicate[7] = 1;
        mock.sdr(2, 0xffff, &duplicate);
        assert!(discover(&mut mock).is_err());
        mock.done();
        let mut mock = Mock::default();
        mock.info(1);
        mock.expect(0x0a, 0x23, &[0, 0, 0, 0, 0, 0xff], &[0xc5]);
        assert!(discover(&mut mock).is_err());
        mock.done();
        let mut mock = Mock::default();
        mock.info(1);
        mock.sdr(0, 0xffff, &record(1, "GPU1 Temp"));
        mock.info(1);
        assert!(discover(&mut mock).is_err());
        mock.done();
    }

    #[test]
    fn empty_available_set_and_disappearing_sensor_are_errors() {
        let mut mock = Mock::default();
        let mut sensors = vec![parse_record(&record(1, "CPU Temp"), 1).unwrap().1.unwrap()];
        mock.expect(4, 0x2d, &[1], &[0, 0, 0x60]);
        assert!(sample(&mut mock, &mut sensors, false).is_err());
        mock.expect(4, 0x2d, &[1], &[0, 50, 0x40]);
        sample(&mut mock, &mut sensors, false).unwrap();
        mock.expect(4, 0x2d, &[1], &[0, 0, 0x60]);
        assert!(sample(&mut mock, &mut sensors, false).is_err());
        mock.done();
    }

    #[test]
    fn absent_m2_completion_cb_matches_hardware_baseline() {
        let mut mock = Mock::default();
        let mut sensors: Vec<_> = [
            (1, "CPU Temp"),
            (2, "System Temp"),
            (3, "Peripheral Temp"),
            (0x4b, "M2NVMeSSD Temp1"),
        ]
        .into_iter()
        .map(|(id, name)| parse_record(&record(id, name), id).unwrap().1.unwrap())
        .collect();
        // Reported pre-activation readings; only the M.2 sensor number is hardware-derived.
        for (number, temperature) in [(1, 64), (2, 57), (3, 54)] {
            mock.expect(4, 0x2d, &[number], &[0, temperature, 0x40]);
        }
        mock.expect(4, 0x2d, &[0x4b], &[0xcb]);
        let result = sample(&mut mock, &mut sensors, true).unwrap();
        assert_eq!((result.maximum, result.count), (64., 3));
        assert_eq!(result.maximum_name, "CPU Temp");
        assert!(!sensors[3].was_available);
        mock.done();
    }

    #[test]
    fn previously_available_m2_completion_cb_is_disappearance() {
        let mut mock = Mock::default();
        let mut sensors: Vec<_> = [(1, "CPU Temp"), (0x4b, "M2NVMeSSD Temp1")]
            .into_iter()
            .map(|(id, name)| parse_record(&record(id, name), id).unwrap().1.unwrap())
            .collect();
        mock.expect(4, 0x2d, &[1], &[0, 64, 0x40]);
        mock.expect(4, 0x2d, &[0x4b], &[0, 55, 0x40]);
        assert_eq!(sample(&mut mock, &mut sensors, false).unwrap().count, 2);
        mock.expect(4, 0x2d, &[1], &[0, 64, 0x40]);
        mock.expect(4, 0x2d, &[0x4b], &[0xcb]);
        let error = sample(&mut mock, &mut sensors, false).err().unwrap();
        assert!(
            error
                .to_string()
                .contains("previously available sensor disappeared"),
            "{error:#}"
        );
        mock.done();
    }

    #[test]
    fn only_sensor_reading_completion_cb_is_unavailable() {
        let mut mock = Mock::default();
        let mut sensors = vec![
            parse_record(&record(0x4b, "M2NVMeSSD Temp1"), 0x4b)
                .unwrap()
                .1
                .unwrap(),
        ];
        for cc in 1..=255 {
            if cc == 0xcb {
                continue;
            }
            mock.expect(4, 0x2d, &[0x4b], &[cc]);
            let error = sample(&mut mock, &mut sensors, false).err().unwrap();
            assert!(
                error
                    .to_string()
                    .contains(&format!("completion code {cc:#04x}")),
                "{error:#}"
            );
        }
        // The generic raw path remains strict, including for 04/2d and OEM commands.
        mock.expect(4, 0x2d, &[0x4b], &[0xcb]);
        assert!(raw(&mut mock, 4, 0x2d, &[0x4b], 0).is_err());
        mock.expect(0x30, 0x45, &[0], &[0xcb]);
        assert!(mode(&mut mock).is_err());
        // Successful responses still require a valid reading payload.
        mock.expect(4, 0x2d, &[0x4b], &[0]);
        assert!(
            sample(&mut mock, &mut sensors, false)
                .err()
                .unwrap()
                .to_string()
                .contains("bad sensor reading length")
        );
        mock.expect(4, 0x2d, &[0x4b], &[0xcb]);
        mock.exchanges.back_mut().unwrap().reply =
            Ok(Response::new(Message::new_raw(5, 0x2e, vec![0xcb]), 0).unwrap());
        assert!(sample(&mut mock, &mut sensors, false).is_err());
        mock.expect(4, 0x2d, &[0x4b], &[0xcb]);
        mock.exchanges.back_mut().unwrap().reply =
            Err(io::Error::new(io::ErrorKind::TimedOut, "mock timeout"));
        assert!(sample(&mut mock, &mut sensors, false).is_err());
        // An absent-only set must not become a successful empty sample.
        mock.expect(4, 0x2d, &[0x4b], &[0xcb]);
        assert!(
            sample(&mut mock, &mut sensors, false)
                .err()
                .unwrap()
                .to_string()
                .contains("no available")
        );
        mock.done();
    }

    #[test]
    fn maximum_covers_all_available_sensors_and_unavailable_can_join() {
        let mut mock = Mock::default();
        let mut sensors: Vec<_> = [(1, "CPU Temp"), (2, "VRM Temp"), (3, "GPU1 Temp")]
            .into_iter()
            .map(|(id, name)| parse_record(&record(id, name), id).unwrap().1.unwrap())
            .collect();
        mock.expect(4, 0x2d, &[1], &[0, 70, 0xc0]);
        mock.expect(4, 0x2d, &[2], &[0, 99, 0x60]);
        let result = sample(&mut mock, &mut sensors, false).unwrap();
        assert_eq!((result.maximum, result.count), (70., 1));
        mock.expect(4, 0x2d, &[1], &[0, 71, 0x40]);
        mock.expect(4, 0x2d, &[2], &[0, 80, 0x40]);
        let result = sample(&mut mock, &mut sensors, false).unwrap();
        assert_eq!((result.maximum, result.count), (80., 2));
        assert_eq!(result.maximum_name, "VRM Temp");
        mock.done();
    }

    #[test]
    fn changed_repository_and_longer_cycle_are_errors() {
        let mut mock = Mock::default();
        mock.info(1);
        mock.sdr(0, 0xffff, &record(1, "CPU Temp"));
        mock.info(2);
        assert!(discover(&mut mock).is_err());
        mock.done();
        let mut mock = Mock::default();
        mock.info(3);
        mock.sdr(0, 2, &record(1, "CPU Temp"));
        mock.sdr(2, 1, &record(2, "VRM Temp"));
        assert!(discover(&mut mock).is_err());
        mock.done();
    }

    #[test]
    fn unchanged_mode_and_duty_do_not_write_but_drift_repairs() {
        let mut mock = Mock::default();
        mock.readback(1, [41, 41]);
        control(&mut mock, [41, 41], Duration::ZERO).unwrap();
        mock.done();
        mock.readback(1, [100, 41]);
        mock.write(0, 41);
        mock.write(1, 41);
        control(&mut mock, [41, 41], Duration::ZERO).unwrap();
        mock.done();
    }

    #[test]
    fn reset_reapplies_both_zones_and_verifies() {
        let mut mock = Mock::default();
        mock.readback(2, [41, 41]);
        mock.expect(0x30, 0x45, &[1, 1], &[0]);
        mock.expect(0x30, 0x45, &[0], &[0, 1]);
        mock.write(0, 41);
        mock.write(1, 41);
        control(&mut mock, [41, 41], Duration::ZERO).unwrap();
        mock.done();
        mock.readback(1, [100, 41]);
        mock.expect(0x30, 0x70, &[0x66, 1, 0, 41], &[0]);
        mock.expect(0x30, 0x70, &[0x66, 0, 0], &[0, 100]);
        assert!(control(&mut mock, [41, 41], Duration::ZERO).is_err());
        mock.done();
    }

    #[test]
    fn failsafe_success_and_transport_failure() {
        let mut mock = Mock::default();
        mock.expect(0x30, 0x45, &[1, 1], &[0]);
        mock.write(0, 100);
        mock.write(1, 100);
        mock.expect(0x30, 0x45, &[0], &[0, 1]);
        failsafe(&mut mock, Duration::ZERO).unwrap();
        mock.done();
        mock.expect(0x30, 0x45, &[1, 1], &[0]);
        mock.exchanges.back_mut().unwrap().reply =
            Err(io::Error::new(io::ErrorKind::TimedOut, "mock timeout"));
        mock.write(0, 100);
        mock.write(1, 100);
        mock.expect(0x30, 0x45, &[0], &[0, 1]);
        assert!(failsafe(&mut mock, Duration::ZERO).is_err());
        mock.done();
    }

    #[test]
    fn failsafe_attempts_both_zones_despite_mode_and_first_zone_failure() {
        let mut mock = Mock::default();
        mock.expect(0x30, 0x45, &[1, 1], &[0xc1]);
        mock.expect(0x30, 0x70, &[0x66, 1, 0, 100], &[0xc1]);
        mock.write(1, 100);
        mock.expect(0x30, 0x45, &[0], &[0, 0]);
        assert!(failsafe(&mut mock, Duration::ZERO).is_err());
        mock.done();
    }
}
