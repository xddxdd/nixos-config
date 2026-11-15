use crate::ipmi;
use anyhow::{Result, ensure};
use ipmi_rs::connection::IpmiConnection;
use std::time::Duration;

pub trait Transport {
    fn command(&mut self, command: u8, data: &[u8]) -> Result<Vec<u8>>;
}
impl<T: IpmiConnection> Transport for T {
    fn command(&mut self, command: u8, data: &[u8]) -> Result<Vec<u8>> {
        ipmi::raw(self, 0x3a, command, data, 0)
    }
}

pub fn read(transport: &mut impl Transport) -> Result<[u8; 8]> {
    let data = transport.command(0x02, &[])?;
    ensure!(
        data.len() == 8 && data.iter().all(|value| *value <= 100),
        "invalid 3a/02 response (expected 8 bytes in 0..=100): {data:?}"
    );
    Ok(data.try_into().expect("length checked"))
}

fn manual_transition(previous: &[u8; 8], payload: &[u8; 8]) -> bool {
    previous
        .iter()
        .zip(payload)
        .any(|(&old, &new)| old == 0 && new > 0)
}

pub fn control(
    transport: &mut impl Transport,
    targets: &[(usize, u8)],
    delay: Duration,
) -> Result<()> {
    ensure!(!targets.is_empty(), "no fan targets");
    ensure!(
        targets
            .iter()
            .all(|(slot, duty)| *slot < 8 && (1..=100).contains(duty)),
        "invalid fan target"
    );
    let previous = read(transport)?;
    let mut payload = previous;
    for &(slot, duty) in targets {
        payload[slot] = duty;
    }
    if payload != previous {
        transport.command(0x01, &payload)?;
        if manual_transition(&previous, &payload) {
            std::thread::sleep(delay);
        }
        ensure!(
            read(transport)? == payload,
            "3a/02 readback mismatch (including unmanaged slots)"
        );
    }
    Ok(())
}

pub fn failsafe(
    transport: &mut impl Transport,
    slots: Option<&[usize]>,
    delay: Duration,
) -> Result<()> {
    ensure!(
        slots.is_none_or(|slots| !slots.is_empty() && slots.iter().all(|slot| *slot < 8)),
        "invalid failsafe slots"
    );
    let previous = read(transport);
    let payload = match (slots, &previous) {
        (Some(slots), Ok(previous)) => {
            let mut payload = *previous;
            for &slot in slots {
                payload[slot] = 100;
            }
            payload
        }
        _ => {
            eprintln!(
                "failsafe: no configured preservation baseline; requesting ALL eight slots 100%"
            );
            [100; 8]
        }
    };
    let mut errors = Vec::new();
    // Initial read failure must not suppress the rescue write; write failure must not suppress verification.
    if let Err(error) = transport.command(0x01, &payload) {
        errors.push(format!("set duty: {error:#}"));
    }
    if previous
        .as_ref()
        .map_or(true, |previous| manual_transition(previous, &payload))
    {
        std::thread::sleep(delay);
    }
    match read(transport) {
        Ok(actual) if actual == payload => {}
        result => errors.push(format!("3a/02 verification: {result:?}")),
    }
    ensure!(
        errors.is_empty(),
        "failsafe incomplete: {}",
        errors.join("; ")
    );
    eprintln!(
        "failsafe: 100% request matched 3a/02 readback (unmanaged slots preserved when baseline available)"
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::VecDeque;

    // Exchanges are synthetic except the explicitly identified captured readbacks.
    #[derive(Default)]
    struct Fake {
        exchanges: VecDeque<(u8, Vec<u8>, Result<Vec<u8>>)>,
    }
    impl Fake {
        fn expect(&mut self, cmd: u8, payload: &[u8], reply: &[u8]) {
            self.exchanges
                .push_back((cmd, payload.to_vec(), Ok(reply.to_vec())));
        }
        fn fail(&mut self, cmd: u8, payload: &[u8]) {
            self.exchanges.push_back((
                cmd,
                payload.to_vec(),
                Err(anyhow::anyhow!("synthetic transport failure")),
            ));
        }
        fn done(self) {
            assert!(self.exchanges.is_empty());
        }
    }
    impl Transport for Fake {
        fn command(&mut self, command: u8, data: &[u8]) -> Result<Vec<u8>> {
            let (cmd, payload, reply) = self.exchanges.pop_front().expect("unexpected command");
            assert_eq!((command, data), (cmd, payload.as_slice()));
            reply
        }
    }
    #[test]
    fn legacy_captured_all_auto_baseline() {
        // Captured 3a/02 response: 00 00 00 00 00 00 00 00, without completion byte.
        let mut fake = Fake::default();
        fake.expect(2, &[], &[0; 8]);
        assert_eq!(read(&mut fake).unwrap(), [0; 8]);
        fake.done();
    }
    #[test]
    fn legacy_captured_full_speed_readback() {
        // Captured 3a/02 after a successful all-slot 100% failsafe request.
        // Only the read response is captured here, not a write acknowledgement.
        let mut fake = Fake::default();
        fake.expect(2, &[], &[0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64]);
        assert_eq!(read(&mut fake).unwrap(), [100; 8]);
        fake.done();
    }
    #[test]
    fn legacy_captured_partial_speed_readbacks() {
        // Captured commissioning readbacks only, not fan-slot mapping in controller logic.
        // Slot 4 at 70%: FRNT1 1600 RPM vs 2700 full; slot 6: FRNT3 1800 vs 2700.
        for captured in [
            [100, 100, 100, 100, 70, 100, 100, 100],
            [100, 100, 100, 100, 100, 100, 70, 100],
        ] {
            let mut fake = Fake::default();
            fake.expect(2, &[], &captured);
            assert_eq!(read(&mut fake).unwrap(), captured);
            fake.done();
        }
    }
    #[test]
    fn synthetic_legacy_preserves_unmanaged_and_skips_unchanged_writes() {
        let mut fake = Fake::default();
        let previous = [0, 0, 37, 0, 40, 0, 88, 0];
        let desired = [0, 75, 37, 0, 100, 0, 88, 0];
        fake.expect(2, &[], &previous);
        fake.expect(1, &desired, &[]);
        fake.expect(2, &[], &desired);
        control(&mut fake, &[(1, 75), (4, 100)], Duration::ZERO).unwrap();
        fake.expect(2, &[], &desired);
        control(&mut fake, &[(1, 75), (4, 100)], Duration::ZERO).unwrap();
        assert!(control(&mut fake, &[(8, 50)], Duration::ZERO).is_err());
        assert!(control(&mut fake, &[(1, 0)], Duration::ZERO).is_err());
        assert!(manual_transition(&previous, &desired));
        let mut changed = desired;
        changed[1] = 70;
        assert!(!manual_transition(&desired, &changed));
        fake.done();
    }
    #[test]
    fn synthetic_legacy_failsafe_preserves_or_falls_back_and_verifies() {
        let mut fake = Fake::default();
        let previous = [0, 75, 37, 0, 60, 0, 88, 0];
        let desired = [0, 100, 37, 0, 100, 0, 88, 0];
        fake.expect(2, &[], &previous);
        fake.expect(1, &desired, &[]);
        fake.expect(2, &[], &desired);
        failsafe(&mut fake, Some(&[1, 4]), Duration::ZERO).unwrap();
        fake.fail(2, &[]);
        fake.expect(1, &[100; 8], &[]);
        fake.expect(2, &[], &[100; 8]);
        failsafe(&mut fake, Some(&[1, 4]), Duration::ZERO).unwrap();
        fake.expect(2, &[], &previous);
        fake.expect(1, &[100; 8], &[]);
        fake.expect(2, &[], &[100; 8]);
        failsafe(&mut fake, None, Duration::ZERO).unwrap();
        fake.expect(2, &[], &previous);
        fake.fail(1, &desired);
        fake.expect(2, &[], &previous);
        assert!(failsafe(&mut fake, Some(&[1, 4]), Duration::ZERO).is_err());
        fake.done();
    }
    #[test]
    fn synthetic_legacy_malformed_state_and_readback_mismatch() {
        for bad in [vec![], vec![0; 7], vec![0; 9], vec![101; 8]] {
            let mut fake = Fake::default();
            fake.expect(2, &[], &bad);
            assert!(read(&mut fake).is_err());
            fake.done();
        }
        let mut fake = Fake::default();
        fake.expect(2, &[], &[0; 8]);
        fake.expect(1, &[75, 0, 0, 0, 0, 0, 0, 0], &[]);
        fake.expect(2, &[], &[0; 8]);
        assert!(control(&mut fake, &[(0, 75)], Duration::ZERO).is_err());
        fake.done();
    }
}
