use std::{
    i16,
    io::{self, BufReader, BufWriter, Read, Write},
};

enum State {
    InitialSilence,
    Sound,
}

const THRESHOLD: f32 = 0.01; // -40dB

fn main() {
    let mut reader = BufReader::new(io::stdin());
    let mut writer = BufWriter::new(io::stdout());
    let mut state = State::InitialSilence;
    let mut read_buffer = [0u8; 2];
    let mut silence_buffer: Vec<u8> = Vec::new();

    while let Ok(bytes_read) = reader.read(&mut read_buffer) {
        if bytes_read == 0 {
            break;
        }
        let value = i16::from_le_bytes(read_buffer);
        let is_silent = (value.abs() as f32) / (i16::MAX as f32) < THRESHOLD;

        match state {
            State::InitialSilence => {
                if is_silent {
                    // Skip
                } else {
                    // Output current segment
                    writer
                        .write_all(&read_buffer)
                        .expect("Failed to write to stdout");
                    state = State::Sound;
                }
            }
            State::Sound => {
                if is_silent {
                    // Buffer until next non-silent segment
                    silence_buffer.extend(&read_buffer);
                } else {
                    // Output all silent segment
                    writer
                        .write_all(&silence_buffer)
                        .expect("Failed to write to stdout");
                    silence_buffer.clear();
                    // Output current segment
                    writer
                        .write_all(&read_buffer)
                        .expect("Failed to write to stdout");
                }
            }
        }
    }
}
