use anyhow::{Result, bail, ensure};

#[derive(Debug)]
pub struct Sensor {
    pub name: String,
    pub body: Vec<u8>,
    pub excluded: bool,
    pub was_available: bool,
}

impl Sensor {
    pub fn key(&self) -> (u8, u8, u8, u8) {
        (
            self.body[0],
            self.body[1] >> 4,
            self.body[1] & 3,
            self.body[2],
        )
    }

    pub fn validate_conversion(&self) -> Result<()> {
        ensure!(
            self.body[8] == 1,
            "{}: temperature is not a threshold sensor",
            self.name
        );
        ensure!(
            self.body[15] & 0x3f == 0 && self.body[16] == 1,
            "{}: expected unmodified Celsius units",
            self.name
        );
        ensure!(
            self.body[15] >> 6 != 3,
            "{}: non-analog temperature format",
            self.name
        );
        ensure!(
            self.body[18] <= 0x0b,
            "{}: unsupported linearization {:#04x}",
            self.name,
            self.body[18]
        );
        Ok(())
    }

    pub fn celsius(&self, raw: u8) -> Result<f64> {
        self.validate_conversion()?;
        let x = match self.body[15] >> 6 {
            0 => f64::from(raw),
            1 if raw & 0x80 != 0 => -f64::from(!raw),
            1 => f64::from(raw),
            2 => f64::from(raw as i8),
            _ => unreachable!(),
        };
        // Full SDR body offsets confirmed against ipmi-rs-core 0.6.0:
        // SensorRecordCommon consumes 18 bytes; FullSensorRecord continues there.
        let m = signed10(self.body[19], self.body[20]);
        let b = signed10(self.body[21], self.body[22]);
        let r_exp = signed4(self.body[24] >> 4);
        let b_exp = signed4(self.body[24] & 0x0f);
        let y = (f64::from(m) * x + f64::from(b) * 10f64.powi(b_exp)) * 10f64.powi(r_exp);
        let temperature = match self.body[18] {
            0 => y,
            1 => y.ln(),
            2 => y.log10(),
            3 => y.log2(),
            4 => y.exp(),
            5 => 10f64.powf(y),
            6 => 2f64.powf(y),
            7 => y.recip(),
            8 => y.powi(2),
            9 => y.powi(3),
            10 => y.sqrt(),
            11 => y.cbrt(),
            _ => unreachable!(),
        };
        ensure!(
            temperature.is_finite(),
            "{}: non-finite temperature from raw {raw:#04x}",
            self.name
        );
        Ok(temperature)
    }

    pub fn reading(&mut self, data: &[u8]) -> Result<Option<f64>> {
        ensure!(
            (2..=4).contains(&data.len()),
            "{}: bad sensor reading length {}",
            self.name,
            data.len()
        );
        // IPMI bit 6 means scanning ENABLED; bit 7 (event messages) is irrelevant.
        if data[1] & 0x20 != 0 || data[1] & 0x40 == 0 {
            ensure!(
                !self.was_available,
                "{}: previously available sensor disappeared or scanning stopped",
                self.name
            );
            return Ok(None);
        }
        let temperature = self.celsius(data[0])?;
        self.was_available = true;
        Ok(Some(temperature))
    }
}

fn signed10(low: u8, high: u8) -> i16 {
    let value = i16::from(low) | (i16::from(high & 0xc0) << 2);
    (value << 6) >> 6
}

fn signed4(value: u8) -> i32 {
    i32::from((value << 4) as i8 >> 4)
}

fn name(type_length: u8, bytes: &[u8]) -> Result<String> {
    ensure!(type_length & 0x20 == 0, "reserved sensor ID length bit set");
    ensure!(
        bytes.len() == usize::from(type_length & 0x1f),
        "sensor ID length mismatch"
    );
    let mut result = String::new();
    match type_length >> 6 {
        1 => {
            let alphabet = b"0123456789 -.:,_";
            for byte in bytes {
                result.push(char::from(alphabet[usize::from(byte >> 4)]));
                result.push(char::from(alphabet[usize::from(byte & 15)]));
            }
        }
        2 => {
            let mut bits = 0u32;
            let mut available = 0;
            for byte in bytes {
                bits |= u32::from(*byte) << available;
                available += 8;
                while available >= 6 {
                    result.push(char::from((bits as u8 & 0x3f) + 0x20));
                    bits >>= 6;
                    available -= 6;
                }
            }
            ensure!(bits == 0, "nonzero padding in packed sensor ID");
        }
        3 => {
            for byte in bytes {
                ensure!(
                    *byte >= 0x20 && *byte != 0x7f,
                    "control character in sensor ID"
                );
                result.push(char::from(*byte));
            }
        }
        _ => bail!("unsupported Unicode/binary sensor ID encoding"),
    }
    ensure!(!result.trim().is_empty(), "empty sensor ID");
    Ok(result)
}

pub fn parse_record(record: &[u8], requested_id: u16) -> Result<(u16, Option<Sensor>)> {
    ensure!(record.len() >= 5, "truncated SDR header");
    let id = u16::from_le_bytes([record[0], record[1]]);
    ensure!(id != 0xffff, "invalid SDR record ID ffff");
    ensure!(
        requested_id == 0 || id == requested_id,
        "SDR ID mismatch: requested {requested_id:04x}, got {id:04x}"
    );
    ensure!(
        record[2] == 0x51,
        "unsupported SDR version {:#04x}",
        record[2]
    );
    ensure!(
        record.len() == 5 + usize::from(record[4]),
        "SDR body length mismatch"
    );
    let body = &record[5..];
    match record[3] {
        1 => {
            ensure!(body.len() >= 43, "truncated full sensor record");
            ensure!(
                body.len() == 43 + usize::from(body[42] & 0x1f),
                "full SDR ID length mismatch"
            );
            if body[7] != 1 {
                return Ok((id, None));
            }
            let name = name(body[42], &body[43..])?;
            // 0x1c is Device Bay, NOT a graphics board. Do not exclude it.
            let excluded = name.to_ascii_lowercase().contains("gpu");
            let sensor = Sensor {
                name,
                body: body.to_vec(),
                excluded,
                was_available: false,
            };
            if !excluded {
                sensor.validate_conversion()?;
                let (owner, channel, _, _) = sensor.key();
                ensure!(
                    owner == 0x20 && channel == 0,
                    "{}: nonlocal sensor owner {owner:#04x}, channel {channel}; IPMB bridging is unsupported",
                    sensor.name
                );
                ensure!(
                    body[2] != 0xff,
                    "{}: reserved sensor number ff",
                    sensor.name
                );
            }
            Ok((id, Some(sensor)))
        }
        2 | 3 => {
            let id_offset = if record[3] == 2 { 26 } else { 11 };
            ensure!(
                body.len() > id_offset,
                "truncated compact/event-only sensor record"
            );
            ensure!(
                body.len() == id_offset + 1 + usize::from(body[id_offset] & 0x1f),
                "compact/event-only SDR ID length mismatch"
            );
            // Compact records have a sensor type at body[7], event-only at body[5].
            let sensor_type = if record[3] == 2 { body[7] } else { body[5] };
            ensure!(
                sensor_type != 1,
                "temperature in unsupported SDR record type {}",
                record[3]
            );
            Ok((id, None))
        }
        0x08 | 0x09 | 0x10..=0x14 | 0xc0..=0xff => {
            ensure!(!body.is_empty(), "empty non-sensor SDR record");
            Ok((id, None))
        }
        ty => bail!("unsupported/reserved SDR record type {ty:#04x}"),
    }
}

#[cfg(test)]
pub mod tests {
    use super::*;

    pub fn record(id: u16, sensor_name: &str) -> Vec<u8> {
        let mut body = vec![0; 43];
        body[0] = 0x20;
        body[2] = id as u8;
        body[3] = 3;
        body[7] = 1;
        body[8] = 1;
        body[16] = 1;
        body[19] = 1;
        body[42] = 0xc0 | sensor_name.len() as u8;
        body.extend_from_slice(sensor_name.as_bytes());
        let [low, high] = id.to_le_bytes();
        let mut result = vec![low, high, 0x51, 1, body.len() as u8];
        result.extend(body);
        result
    }

    fn sensor() -> Sensor {
        parse_record(&record(1, "CPU Temp"), 1).unwrap().1.unwrap()
    }

    #[test]
    fn gpu_exclusion_precedes_unsupported_conversion_and_owner() {
        let mut record = record(1, "gPu1 Temp");
        record[5] = 0x30;
        record[5 + 15] = 0xc0;
        record[5 + 18] = 0x70;
        assert!(parse_record(&record, 1).unwrap().1.unwrap().excluded);
        record[5 + 43] = b'C';
        assert!(parse_record(&record, 1).is_err());
        let mut record = self::record(2, "Device Temp");
        record[5 + 3] = 0x1c;
        assert!(!parse_record(&record, 2).unwrap().1.unwrap().excluded);
    }

    #[test]
    fn crate_dell_r630_temperature_fixture() {
        // ipmi-rs-core 0.6.0 src/tests/dell_r630.rs: INLET_TEMP_SDR/READING.
        let record = [
            0x12, 0x00, 0x51, 0x01, 0x35, 0x20, 0x00, 0x04, 0x07, 0x01, 0x7f, 0x68, 0x01, 0x01,
            0x85, 0x32, 0x85, 0x32, 0x1b, 0x09, 0x00, 0x01, 0x00, 0x00, 0x01, 0x02, 0x80, 0xc2,
            0x30, 0x00, 0x07, 0x97, 0xc5, 0x8b, 0xff, 0x00, 0xff, 0xaf, 0xaa, 0x00, 0x79, 0x83,
            0x01, 0x01, 0x00, 0x00, 0x00, 0xca, 0x49, 0x6e, 0x6c, 0x65, 0x74, 0x20, 0x54, 0x65,
            0x6d, 0x70,
        ];
        let mut sensor = parse_record(&record, 0x12).unwrap().1.unwrap();
        assert_eq!(sensor.name, "Inlet Temp");
        assert_eq!(sensor.reading(&[0x99, 0xc0, 0xc0]).unwrap(), Some(25.));
    }

    #[test]
    fn signed_coefficients_exponents_and_formats() {
        assert_eq!(signed10(0, 0x40), 256);
        assert_eq!(signed10(0, 0x80), -512);
        assert_eq!(signed10(0xff, 0xff), -1);
        assert_eq!(signed4(8), -8);
        assert_eq!(signed4(15), -1);
        let mut s = sensor();
        assert_eq!(s.celsius(200).unwrap(), 200.);
        s.body[15] = 0x40;
        assert_eq!(s.celsius(5).unwrap(), 5.);
        assert_eq!(s.celsius(0xfa).unwrap(), -5.);
        assert_eq!(s.celsius(0xff).unwrap(), 0.);
        s.body[15] = 0x80;
        assert_eq!(s.celsius(0xfb).unwrap(), -5.);
        s.body[15] = 0;
        s.body[19] = 0xfe;
        s.body[20] = 0xc0; // M = -2
        s.body[21] = 0xf6;
        s.body[22] = 0xc0; // B = -10
        s.body[24] = 0xf1; // R = -1, B exponent = 1
        assert_eq!(s.celsius(25).unwrap(), -15.);
        s.body[19] = 0;
        s.body[20] = 0x40; // M = +256
        s.body[21] = 0;
        s.body[22] = 0;
        s.body[24] = 0;
        assert_eq!(s.celsius(2).unwrap(), 512.);
    }

    #[test]
    fn nonlinear_and_invalid_domains() {
        let mut s = sensor();
        s.body[18] = 2;
        assert_eq!(s.celsius(100).unwrap(), 2.);
        assert!(s.celsius(0).is_err());
        s.body[18] = 7;
        assert_eq!(s.celsius(2).unwrap(), 0.5);
        assert!(s.celsius(0).is_err());
        s.body[18] = 10;
        s.body[15] = 0x80;
        assert!(s.celsius(0xff).is_err());
        s.body[18] = 11;
        assert_eq!(s.celsius(0xf8).unwrap(), -2.);
        s.body[18] = 0x70;
        assert!(s.celsius(1).is_err());
    }

    #[test]
    fn reading_flags_and_disappearance() {
        let mut s = sensor();
        assert_eq!(s.reading(&[50, 0x60]).unwrap(), None);
        assert_eq!(s.reading(&[50, 0]).unwrap(), None);
        assert_eq!(s.reading(&[50, 0x40]).unwrap(), Some(50.));
        assert_eq!(s.reading(&[51, 0xc0]).unwrap(), Some(51.));
        assert!(s.reading(&[51, 0x60]).is_err());
        assert!(s.reading(&[51, 0x80]).is_err());
        assert!(s.reading(&[50]).is_err());
        assert!(s.reading(&[50, 0x40, 0, 0, 0]).is_err());
    }

    #[test]
    fn malformed_records_and_nonlocal_owners_fail() {
        let good = record(1, "CPU Temp");
        for length in 0..good.len() {
            assert!(parse_record(&good[..length], 1).is_err());
        }
        for (offset, value) in [
            (0, 2),
            (2, 0),
            (3, 0),
            (4, 1),
            (5, 0x30),
            (6, 0x10),
            (47, 0xdf),
            (21, 2),
            (20, 0xc0),
        ] {
            let mut bad = good.clone();
            bad[offset] = value;
            assert!(parse_record(&bad, 1).is_err(), "offset {offset}");
        }
    }

    #[test]
    fn sensor_owner_channel_and_lun_fields() {
        let mut bytes = record(1, "CPU Temp");
        // Bits 3:2 are the FRU inventory owner's LUN, not the sensor owner's LUN.
        bytes[6] = 0x0e;
        let sensor = parse_record(&bytes, 1).unwrap().1.unwrap();
        assert_eq!(sensor.key(), (0x20, 0, 2, 1));
        bytes[7] = 0xff;
        assert!(parse_record(&bytes, 1).is_err());
    }

    #[test]
    fn sensor_name_encodings() {
        assert_eq!(name(0xc3, b"GPU").unwrap(), "GPU");
        assert_eq!(name(0x42, &[0x12, 0xab]).unwrap(), "12 -");
        // 6-bit ASCII packs least-significant character first (G=39, P=48, U=53).
        let packed = 39u32 | (48 << 6) | (53 << 12);
        assert_eq!(name(0x83, &packed.to_le_bytes()[..3]).unwrap(), "GPU ");
        assert!(name(0x03, b"GPU").is_err());
        assert!(name(0xc0, b"").is_err());
        assert!(name(0xe3, b"GPU").is_err());
    }
}
