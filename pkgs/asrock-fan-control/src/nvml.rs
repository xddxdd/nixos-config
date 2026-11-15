use anyhow::{Context, Result, ensure};
use libloading::Library;
use std::{
    ffi::{CStr, CString, c_char, c_uint, c_void},
    sync::mpsc,
    time::Duration,
};

// NVIDIA/nvidia-settings 505c69475ed90a19c97660dc4217449ef07705fc, src/nvml.h:
// pointer typedef L156; declarations L4478, L4544, L5304, L5412, L6654,
// L6744. The go-nvml header wraps the pointer for cgo; it is not the native ABI.
// No ordinal API is loaded.
type Device = *mut c_void;
type Simple = unsafe extern "C" fn() -> c_uint;
type Handle = unsafe extern "C" fn(*const c_char, *mut Device) -> c_uint;
type Name = unsafe extern "C" fn(Device, *mut c_char, c_uint) -> c_uint;
type Temperature = unsafe extern "C" fn(Device, c_uint, *mut c_uint) -> c_uint;

struct Nvml {
    handle: Handle,
    name: Name,
    temperature: Temperature,
    threshold: Temperature,
    shutdown: Simple,
    _library: Option<Library>,
}

#[derive(Debug, Clone)]
pub struct Reading {
    pub uuid: String,
    pub name: String,
    pub temperature: u32,
    pub slowdown: u32,
    pub shutdown: u32,
}

fn check(code: c_uint, operation: &str) -> Result<()> {
    ensure!(code == 0, "{operation}: NVML error {code}");
    Ok(())
}

impl Nvml {
    fn load() -> Result<Self> {
        // All symbols are resolved before initialization; Library outlives copied pointers.
        unsafe {
            let library = Library::new("/run/opengl-driver/lib/libnvidia-ml.so.1")
                .context("load NVIDIA NVML")?;
            let init: Simple = *library.get(b"nvmlInit_v2\0")?;
            let handle = *library.get(b"nvmlDeviceGetHandleByUUID\0")?;
            let name = *library.get(b"nvmlDeviceGetName\0")?;
            let temperature = *library.get(b"nvmlDeviceGetTemperature\0")?;
            let threshold = *library.get(b"nvmlDeviceGetTemperatureThreshold\0")?;
            let shutdown = *library.get(b"nvmlShutdown\0")?;
            check(init(), "nvmlInit_v2")?;
            Ok(Self {
                handle,
                name,
                temperature,
                threshold,
                shutdown,
                _library: Some(library),
            })
        }
    }

    fn read(&self, uuid: &str) -> Result<Reading> {
        let uuid_c = CString::new(uuid)?;
        let mut device: Device = std::ptr::null_mut();
        let mut name = [0u8; 64];
        let (mut temperature, mut slowdown, mut shutdown) = (0, 0, 0);
        // Exact C signatures above; every output is checked before use.
        unsafe {
            check(
                (self.handle)(uuid_c.as_ptr(), &mut device),
                "nvmlDeviceGetHandleByUUID",
            )?;
            ensure!(!device.is_null(), "NVML returned a null device for {uuid}");
            check(
                (self.name)(device, name.as_mut_ptr().cast(), name.len() as c_uint),
                "nvmlDeviceGetName",
            )?;
            check(
                (self.temperature)(device, 0, &mut temperature),
                "nvmlDeviceGetTemperature",
            )?;
            check(
                (self.threshold)(device, 1, &mut slowdown),
                "NVML slowdown threshold",
            )?;
            check(
                (self.threshold)(device, 0, &mut shutdown),
                "NVML shutdown threshold",
            )?;
        }
        let name = CStr::from_bytes_until_nul(&name)
            .context("unterminated NVML device name")?
            .to_str()?
            .to_owned();
        ensure!(
            temperature <= 150,
            "implausible GPU temperature for {uuid}: {temperature}"
        );
        ensure!(
            slowdown > 90 && slowdown <= shutdown && shutdown <= 150,
            "unsafe/invalid temperature limits for {uuid}: slowdown={slowdown}, shutdown={shutdown}"
        );
        Ok(Reading {
            uuid: uuid.into(),
            name,
            temperature,
            slowdown,
            shutdown,
        })
    }
}

impl Drop for Nvml {
    fn drop(&mut self) {
        // Runs only in the worker: a stuck driver shutdown must not block IPMI cleanup.
        let code = unsafe { (self.shutdown)() };
        if code != 0 {
            eprintln!("nvmlShutdown: NVML error {code}");
        }
    }
}

fn collect_readings(
    uuids: &[String],
    mut read: impl FnMut(&str) -> Result<Reading>,
) -> Result<Vec<Reading>> {
    uuids
        .iter()
        .map(|uuid| {
            let reading = read(uuid)?;
            ensure!(
                reading.temperature < 90,
                "GPU {uuid}: {} C >=90 C: emergency full-speed shutdown",
                reading.temperature
            );
            Ok(reading)
        })
        .collect()
}

pub struct Reader {
    request: mpsc::Sender<()>,
    response: mpsc::Receiver<std::result::Result<Vec<Reading>, String>>,
}
impl Reader {
    pub fn start(uuids: Vec<String>) -> Result<Self> {
        let (request, requests) = mpsc::channel();
        let (response, responses) = mpsc::channel();
        std::thread::Builder::new()
            .name("nvml".into())
            .spawn(move || {
                let api = Nvml::load();
                while requests.recv().is_ok() {
                    let result = match &api {
                        Ok(api) => collect_readings(&uuids, |uuid| api.read(uuid)),
                        Err(error) => Err(anyhow::anyhow!("{error:#}")),
                    };
                    if response
                        .send(result.map_err(|error| format!("{error:#}")))
                        .is_err()
                    {
                        break;
                    }
                }
            })
            .context("spawn NVML worker")?;
        Ok(Self {
            request,
            response: responses,
        })
    }
    pub fn read(&self) -> Result<Vec<Reading>> {
        self.read_timeout(Duration::from_secs(8))
    }
    fn read_timeout(&self, timeout: Duration) -> Result<Vec<Reading>> {
        self.request.send(()).context("NVML worker stopped")?;
        self.response
            .recv_timeout(timeout)
            .context("NVML worker timed out/stopped")?
            .map_err(anyhow::Error::msg)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::Cell;
    thread_local! { static FAILURE: Cell<u32> = const { Cell::new(0) }; }
    unsafe extern "C" fn handle(uuid: *const c_char, output: *mut Device) -> c_uint {
        assert_eq!(
            unsafe { CStr::from_ptr(uuid) }.to_str().unwrap(),
            "GPU-synthetic"
        );
        if FAILURE.get() == 1 {
            return 6;
        } // NVML_ERROR_NOT_FOUND
        unsafe {
            *output = std::ptr::dangling_mut::<u8>().cast();
        }
        0
    }
    unsafe extern "C" fn name(_: Device, output: *mut c_char, length: c_uint) -> c_uint {
        assert_eq!(length, 64);
        let value = match FAILURE.get() {
            2 => b"Tesla P100\0",
            7 => b"Tesla P4\0\0\0",
            _ => b"Tesla P40\0\0",
        };
        unsafe {
            std::ptr::copy_nonoverlapping(value.as_ptr(), output.cast(), value.len());
        }
        0
    }
    unsafe extern "C" fn temperature(_: Device, sensor: c_uint, output: *mut c_uint) -> c_uint {
        assert_eq!(sensor, 0);
        if FAILURE.get() == 3 {
            return 15;
        } // NVML_ERROR_GPU_IS_LOST
        unsafe {
            *output = if FAILURE.get() == 4 { 500 } else { 70 };
        }
        0
    }
    unsafe extern "C" fn threshold(_: Device, kind: c_uint, output: *mut c_uint) -> c_uint {
        if FAILURE.get() == 5 {
            return 3;
        } // NVML_ERROR_NOT_SUPPORTED
        unsafe {
            *output = match (FAILURE.get(), kind) {
                (6, _) => 85,
                (7, 1) => 91,
                (7, _) => 94,
                (_, 1) => 92,
                _ => 95,
            };
        }
        0
    }
    unsafe extern "C" fn shutdown() -> c_uint {
        0
    }
    #[test]
    fn synthetic_ffi_errors_uuid_identity_and_temperature_limits() {
        let api = Nvml {
            handle,
            name,
            temperature,
            threshold,
            shutdown,
            _library: None,
        };
        FAILURE.set(0);
        let reading = api.read("GPU-synthetic").unwrap();
        assert_eq!(
            (reading.temperature, reading.slowdown, reading.shutdown),
            (70, 92, 95)
        );
        for (scenario, expected_name, slowdown, shutdown) in
            [(2, "Tesla P100", 92, 95), (7, "Tesla P4", 91, 94)]
        {
            FAILURE.set(scenario);
            let reading = api.read("GPU-synthetic").unwrap();
            assert_eq!(
                (reading.name.as_str(), reading.slowdown, reading.shutdown),
                (expected_name, slowdown, shutdown)
            );
        }
        for failure in [1, 3, 4, 5, 6] {
            FAILURE.set(failure);
            assert!(
                api.read("GPU-synthetic").is_err(),
                "failure scenario {failure}"
            );
        }
        FAILURE.set(0);
        assert!(api.read("GPU-\0").is_err());
        assert!(check(9, "driver").is_err());
    }
    #[test]
    fn collection_stops_before_next_getter_when_first_gpu_is_hot() {
        let uuids = ["GPU-first-synthetic".into(), "GPU-second-synthetic".into()];
        for temperature in [89, 90, 95] {
            let mut calls = 0;
            let result = collect_readings(&uuids, |uuid| {
                calls += 1;
                assert!(
                    temperature < 90 || calls == 1,
                    "queried second GPU after emergency"
                );
                Ok(Reading {
                    uuid: uuid.into(),
                    name: "Tesla P40".into(),
                    temperature,
                    slowdown: 92,
                    shutdown: 95,
                })
            });
            if temperature < 90 {
                assert_eq!(result.unwrap().len(), 2);
                assert_eq!(calls, 2);
            } else {
                let error = result.unwrap_err().to_string();
                assert!(
                    error.contains(&uuids[0])
                        && error.contains(&format!("{temperature} C"))
                        && error.contains("emergency")
                );
                assert_eq!(calls, 1);
            }
        }
    }
    #[test]
    fn stuck_worker_times_out() {
        let (request, _requests) = mpsc::channel();
        let (_responses, response) = mpsc::channel();
        let reader = Reader { request, response };
        assert!(
            reader
                .read_timeout(Duration::from_millis(1))
                .unwrap_err()
                .to_string()
                .contains("timed out")
        );
    }
    #[test]
    fn disconnected_worker_is_an_error() {
        let (request, receiver) = mpsc::channel();
        drop(receiver);
        let (sender, response) = mpsc::channel();
        drop(sender);
        assert!(Reader { request, response }.read().is_err());
    }
}
