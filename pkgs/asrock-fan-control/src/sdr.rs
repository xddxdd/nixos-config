use crate::shared_sdr;
use anyhow::Result;

pub use shared_sdr::Sensor;
#[cfg(test)]
pub use shared_sdr::tests;

pub fn parse_record(record: &[u8], requested_id: u16) -> Result<(u16, Option<Sensor>)> {
    // ASRock emits version 0 for non-temperature event-only records. Normalize only
    // that case, leaving temperature/version and all structural checks to smfc.
    if record.len() >= 17
        && record[2] == 0
        && record[3] == 3
        && record.len() == 5 + usize::from(record[4])
        && record[10] != 1
    {
        let mut normalized = record.to_vec();
        normalized[2] = 0x51;
        shared_sdr::parse_record(&normalized, requested_id)
    } else {
        shared_sdr::parse_record(record, requested_id)
    }
}

#[cfg(test)]
mod shim_tests {
    use super::*;

    // Captured Get SDR 0036 response: next ID, full SDR header, then event-only
    // Memory (0x0c) body with ID "DRAM ECC ErrorE1". No completion byte included.
    const GET_SDR_0036: &[u8] = &[
        0x37, 0x00, 0x36, 0x00, 0x00, 0x03, 0x1c, 0x21, 0x00, 0xd8, 0x00, 0x00, 0x0c, 0x6f, 0x00,
        0x00, 0x00, 0x00, 0xd0, 0x44, 0x52, 0x41, 0x4d, 0x20, 0x45, 0x43, 0x43, 0x20, 0x45, 0x72,
        0x72, 0x6f, 0x72, 0x45, 0x31,
    ];

    #[test]
    fn captured_version_zero_memory_event_record_is_ignored() {
        let record = &GET_SDR_0036[2..];
        assert_eq!(&GET_SDR_0036[..2], &[0x37, 0]);
        assert!(
            shared_sdr::parse_record(record, 0x36)
                .unwrap_err()
                .to_string()
                .contains("unsupported SDR version 0x00")
        );
        let (id, sensor) = parse_record(record, 0x36).unwrap();
        assert_eq!(id, 0x36);
        assert!(sensor.is_none());
        assert_eq!(record[2], 0);
    }

    #[test]
    fn malformed_event_records_still_fail() {
        let record = &GET_SDR_0036[2..];
        for length in 0..record.len() {
            assert!(
                parse_record(&record[..length], 0x36).is_err(),
                "truncation {length}"
            );
        }
        assert!(parse_record(record, 0x35).is_err());
        let mut extra = record.to_vec();
        extra.push(0);
        assert!(parse_record(&extra, 0x36).is_err());
        for (offset, value) in [(0, 0xff), (4, 0), (16, 0xdf)] {
            let mut malformed = record.to_vec();
            malformed[offset] = value;
            assert!(parse_record(&malformed, 0x36).is_err());
        }
    }

    #[test]
    fn other_versions_types_and_temperature_records_remain_strict() {
        let record = &GET_SDR_0036[2..];
        for version in [1, 0x50, 0x52, 0xff] {
            let mut changed = record.to_vec();
            changed[2] = version;
            assert!(parse_record(&changed, 0x36).is_err());
        }
        for kind in [1, 2, 0x08, 0xc0] {
            let mut changed = record.to_vec();
            changed[3] = kind;
            assert!(parse_record(&changed, 0x36).is_err());
        }
        let mut event_temperature = record.to_vec();
        event_temperature[10] = 1;
        assert!(
            parse_record(&event_temperature, 0x36)
                .unwrap_err()
                .to_string()
                .contains("unsupported SDR version 0x00")
        );
        event_temperature[2] = 0x51;
        assert!(parse_record(&event_temperature, 0x36).is_err());
        let mut full_temperature = tests::record(1, "CPU Temp");
        full_temperature[2] = 0;
        assert!(parse_record(&full_temperature, 1).is_err());
        full_temperature[2] = 0x51;
        assert!(parse_record(&full_temperature, 1).unwrap().1.is_some());
    }
}
