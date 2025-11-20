use signal_hook::{consts::SIGINT, consts::SIGTERM, iterator::Signals};
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::thread;
use std::time::Duration;

const COLORS: [(u8, u8, u8); 3] = [
    (0x03, 0xA9, 0xF4), // #03A9F4
    (0xFF, 0xEB, 0x3B), // #FFEB3B
    (0xE5, 0x39, 0x35), // #E53935
];

const RGB_ZONES_PATH: &str = "/sys/devices/platform/hp-wmi/rgb_zones";
const LID_STATE_PATH: &str = "/proc/acpi/button/lid/LID0/state";

fn blend_color(color1: (u8, u8, u8), color2: (u8, u8, u8), color2_weight: f64) -> (u8, u8, u8) {
    let r1 = color1.0 as f64;
    let g1 = color1.1 as f64;
    let b1 = color1.2 as f64;

    let r2 = color2.0 as f64;
    let g2 = color2.1 as f64;
    let b2 = color2.2 as f64;

    let r = (r1 * (1.0 - color2_weight) + r2 * color2_weight).round() as u8;
    let g = (g1 * (1.0 - color2_weight) + g2 * color2_weight).round() as u8;
    let b = (b1 * (1.0 - color2_weight) + b2 * color2_weight).round() as u8;

    (r, g, b)
}

fn set_color(color: (u8, u8, u8)) -> io::Result<()> {
    let path = Path::new(RGB_ZONES_PATH);

    // Skip if kernel module isn't initialized yet
    if !path.exists() {
        return Ok(());
    }

    let color_str = format!("{:02X}{:02X}{:02X}\n", color.0, color.1, color.2);

    for entry in fs::read_dir(path)? {
        let entry = entry?;
        let zone_path = entry.path();

        if zone_path.is_file() {
            let mut file = fs::OpenOptions::new()
                .write(true)
                .append(true)
                .open(&zone_path)?;

            file.write_all(color_str.as_bytes())?;
        }
    }

    Ok(())
}

fn get_load() -> f64 {
    unsafe {
        let mut loadavg: [f64; 3] = [0.0, 0.0, 0.0];
        if libc::getloadavg(loadavg.as_mut_ptr(), 3) > 0 {
            let cpu_count = libc::sysconf(libc::_SC_NPROCESSORS_ONLN) as f64;
            if cpu_count > 0.0 {
                return (loadavg[0] / cpu_count).max(0.0);
            }
        }
    }
    0.0
}

fn is_lid_open() -> io::Result<bool> {
    let content = fs::read_to_string(LID_STATE_PATH)?;
    Ok(content.trim().contains("open"))
}

fn handle_signals(running: Arc<AtomicBool>) -> io::Result<()> {
    let mut signals = Signals::new(&[SIGINT, SIGTERM])?;

    thread::spawn(move || {
        for sig in signals.forever() {
            match sig {
                SIGINT | SIGTERM => {
                    println!("\nReceived signal {}, shutting down gracefully...", sig);
                    running.store(false, Ordering::SeqCst);
                    break;
                }
                _ => {}
            }
        }
    });

    Ok(())
}

fn main() -> io::Result<()> {
    let running = Arc::new(AtomicBool::new(true));

    // Set up signal handlers in a separate thread
    handle_signals(running.clone())?;

    println!("HP Keyboard Backlight Controller started");
    println!("Press Ctrl+C to stop gracefully");

    let mut last_state: Option<(f64, bool)> = None;
    let mut error_count = 0;
    const MAX_ERRORS: usize = 10;

    while running.load(Ordering::SeqCst) {
        let load = get_load();
        let lid_open = match is_lid_open() {
            Ok(state) => state,
            Err(e) => {
                eprintln!("Warning: Failed to read lid state: {}. Assuming open.", e);
                true // Default to open if we can't read lid state
            }
        };

        let current_state = (load, lid_open);

        if last_state != Some(current_state) {
            last_state = Some(current_state);

            let result_color = if lid_open {
                let blend_idx = load as usize;
                if blend_idx >= COLORS.len() - 1 {
                    COLORS[COLORS.len() - 1]
                } else {
                    let weight = load - blend_idx as f64;
                    blend_color(COLORS[blend_idx], COLORS[blend_idx + 1], weight)
                }
            } else {
                // Disable backlight if lid is closed
                (0, 0, 0)
            };

            if let Err(e) = set_color(result_color) {
                eprintln!("Warning: Failed to set color: {}", e);
                error_count += 1;
                if error_count >= MAX_ERRORS {
                    eprintln!("Too many consecutive errors, exiting");
                    break;
                }
            } else {
                error_count = 0; // Reset error count on success
            }
        }

        thread::sleep(Duration::from_secs(1));
    }

    // Reset color on exit
    if let Err(e) = set_color(COLORS[0]) {
        eprintln!("Failed to reset color on exit: {}", e);
    }
    println!("HP Keyboard Backlight Controller stopped");
    Ok(())
}
