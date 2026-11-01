use hmac::{Hmac, Mac};
use regex::Regex;
use serde::Serialize;
use sha2::Sha256;
use socket2::{Domain, Protocol, Socket, Type};
use std::{
    collections::HashMap,
    env, fs,
    io::{self, Read, Write},
    net::{IpAddr, Ipv6Addr, SocketAddr, TcpListener, TcpStream},
    process::{Command, Stdio},
    sync::{Mutex, OnceLock},
    thread,
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};

// Protocol and process behavior follow the pinned official Python agent 1.2.0:
// sha256-nL4sIU3EQmKiTyGV+ljk4erz7ihYTsWkO0WlCzeKVV4=.
const VERSION: &str = "1.2.0";
const HEADER_SIZE: usize = 74;
const MAX_BODY_SIZE: usize = 2000;
const MAX_WORKERS: usize = 8;
const TIMESTAMP_SKEW: f64 = 30.0;
const AUTH_DEADLINE: Duration = Duration::from_secs(3);
const CONN_TIMEOUT: Duration = Duration::from_secs(15);

type HmacSha256 = Hmac<Sha256>;

fn now() -> f64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs_f64()
}

fn log(level: &str, message: impl std::fmt::Display) {
    static THRESHOLD: OnceLock<u8> = OnceLock::new();
    fn priority(level: &str) -> u8 {
        match level {
            "NOTSET" => 0,
            "DEBUG" => 10,
            "WARNING" | "WARN" => 30,
            "ERROR" => 40,
            "CRITICAL" | "FATAL" => 50,
            _ => 20,
        }
    }
    let threshold = THRESHOLD
        .get_or_init(|| priority(&env::var("LOG_LEVEL").unwrap_or_default().to_uppercase()));
    if priority(level) >= *threshold {
        eprintln!("{:.3} [{level}] {message}", now());
    }
}

#[derive(Debug, Default, Serialize)]
struct PingResult {
    reachable: bool,
    sent: u64,
    recv: u64,
    latency: Option<f64>,
    jitter: Option<f64>,
    min_rtt: Option<f64>,
    max_rtt: Option<f64>,
    version: Option<&'static str>,
}

fn parse_ping_output(output: &str) -> PingResult {
    static PACKETS: OnceLock<Regex> = OnceLock::new();
    static RTT: OnceLock<Regex> = OnceLock::new();
    let mut result = PingResult::default();
    if let Some(captures) = PACKETS
        .get_or_init(|| {
            Regex::new(r"(\d+) packets transmitted, (\d+) (?:packets )?received").unwrap()
        })
        .captures(output)
    {
        result.sent = captures[1].parse().unwrap_or_default();
        result.recv = captures[2].parse().unwrap_or_default();
        result.reachable = result.recv > 0;
    }
    if let Some(captures) = RTT
        .get_or_init(|| Regex::new(r"(\d+\.\d+)/(\d+\.\d+)/(\d+\.\d+)/(\d+\.\d+)").unwrap())
        .captures(output)
    {
        result.min_rtt = captures[1].parse().ok();
        result.latency = captures[2].parse().ok();
        result.max_rtt = captures[3].parse().ok();
        result.jitter = captures[4].parse().ok();
    }
    result
}

fn run_ping(ip: &str) -> PingResult {
    let run = || -> io::Result<PingResult> {
        let mut child = Command::new("ping")
            .args(["-n", "-q", "-c", "4", "-w", "6", ip])
            .env_clear()
            .env("LANG", "C")
            .env("LC_ALL", "C")
            .env(
                "PATH",
                env::var_os("PATH").unwrap_or_else(|| "/usr/bin:/bin".into()),
            )
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;
        // Drain both pipes while waiting, like subprocess.run(capture_output=True).
        let mut stdout = child.stdout.take().unwrap();
        let mut stderr = child.stderr.take().unwrap();
        let out = thread::spawn(move || {
            let mut data = String::new();
            stdout.read_to_string(&mut data).map(|_| data)
        });
        let err = thread::spawn(move || {
            let mut data = String::new();
            stderr.read_to_string(&mut data).map(|_| data)
        });
        let deadline = Instant::now() + Duration::from_secs(10);
        let status = loop {
            match child.try_wait() {
                Ok(Some(_)) => break Ok(()), // Python parses stdout regardless of exit status.
                Ok(None) if Instant::now() < deadline => {
                    thread::sleep(Duration::from_millis(10));
                }
                result => {
                    let _ = child.kill();
                    let _ = child.wait();
                    break match result {
                        Err(error) => Err(error),
                        _ => Err(io::Error::new(io::ErrorKind::TimedOut, "ping timed out")),
                    };
                }
            }
        };
        let stdout = out.join().unwrap();
        let stderr = err.join().unwrap();
        status?;
        stderr?;
        Ok(parse_ping_output(&stdout?))
    };
    match run() {
        Ok(result) => result,
        Err(error) => {
            log("ERROR", format_args!("Ping to {ip} failed: {error}"));
            PingResult::default()
        }
    }
}

// json.dumps uses spaces after commas and colons; these bytes are authenticated.
struct PythonJson;
impl serde_json::ser::Formatter for PythonJson {
    fn begin_object_key<W: ?Sized + Write>(
        &mut self,
        writer: &mut W,
        first: bool,
    ) -> io::Result<()> {
        if !first {
            writer.write_all(b", ")?;
        }
        Ok(())
    }

    fn begin_object_value<W: ?Sized + Write>(&mut self, writer: &mut W) -> io::Result<()> {
        writer.write_all(b": ")
    }
}

fn decode_request(body: &[u8]) -> io::Result<HashMap<String, Box<serde_json::value::RawValue>>> {
    // Python's JSON accepts nonfinite numbers and unpaired surrogate escapes.
    // Neither can equal a supported command or literal IP. Normalize them only
    // after authentication, preserving acceptance of otherwise ignored fields.
    let mut normalized = Vec::with_capacity(body.len());
    let mut in_string = false;
    let mut i = 0;
    while i < body.len() {
        if body[i] == b'"' {
            in_string = !in_string;
        } else if in_string && body[i] == b'\\' {
            let surrogate = body[i..].starts_with(b"\\u")
                && body
                    .get(i + 2..i + 6)
                    .and_then(|digits| std::str::from_utf8(digits).ok())
                    .and_then(|digits| u16::from_str_radix(digits, 16).ok())
                    .is_some_and(|code| (0xd800..=0xdfff).contains(&code));
            if surrogate {
                normalized.extend_from_slice(b"\\ufffd");
                i += 6;
            } else {
                let end = (i + 2).min(body.len());
                normalized.extend_from_slice(&body[i..end]);
                i = end;
            }
            continue;
        } else if !in_string
            && let Some(token) = [b"NaN".as_slice(), b"Infinity", b"-Infinity"]
                .into_iter()
                .find(|token| body[i..].starts_with(token))
        {
            normalized.extend_from_slice(b"null");
            i += token.len();
            continue;
        }
        normalized.push(body[i]);
        i += 1;
    }
    // Retain raw values: unused fields and non-string commands/IPs need no
    // numeric conversion, including Python's arbitrarily large JSON numbers.
    serde_json::from_str(std::str::from_utf8(&normalized).map_err(io::Error::other)?)
        .map_err(io::Error::other)
}

struct Agent {
    key: [u8; 32],
    nonces: Mutex<HashMap<[u8; 32], f64>>,
}

impl Agent {
    fn mac(&self, marker: &[u8], ts: &[u8], nonce: &[u8], body: &[u8]) -> HmacSha256 {
        let mut mac = HmacSha256::new_from_slice(&self.key).unwrap();
        for part in [marker, ts, nonce, body] {
            mac.update(part);
        }
        mac
    }

    fn handle(&self, conn: &mut TcpStream) -> io::Result<()> {
        let deadline = Instant::now() + AUTH_DEADLINE;
        let mut header = [0; HEADER_SIZE];
        recv_exact(conn, &mut header, deadline)?;
        let body_len = u16::from_be_bytes(header[72..74].try_into().unwrap()) as usize;
        if body_len > MAX_BODY_SIZE {
            return Ok(());
        }
        let mut body = vec![0; body_len];
        recv_exact(conn, &mut body, deadline)?;
        let ts = &header[32..40];
        let nonce = &header[40..72];
        if self
            .mac(b"\x00", ts, nonce, &body)
            .verify_slice(&header[..32])
            .is_err()
        {
            if self
                .mac(b"", ts, nonce, &body)
                .verify_slice(&header[..32])
                .is_err()
            {
                return Ok(());
            }
            log("DEBUG", "accepted legacy mac");
        }
        let req_ts = u64::from_be_bytes(ts.try_into().unwrap()) as f64;
        if (now() - req_ts).abs() > TIMESTAMP_SKEW {
            log("WARNING", "rejected stale request");
            return Ok(());
        }
        {
            let mut nonces = self.nonces.lock().unwrap();
            let now = now();
            nonces.retain(|_, expiry| *expiry >= now);
            if nonces.contains_key(nonce) {
                log("WARNING", "rejected replayed nonce");
                return Ok(());
            }
            nonces.insert(nonce.try_into().unwrap(), req_ts + TIMESTAMP_SKEW);
        }
        let request = decode_request(&body)?;
        let mut payload = Vec::new();
        let mut encoder = serde_json::Serializer::with_formatter(&mut payload, PythonJson);
        match request
            .get("command")
            .and_then(|value| serde_json::from_str::<String>(value.get()).ok())
            .as_deref()
        {
            Some("version") => {
                log("INFO", "version check");
                serde_json::json!({"version": VERSION}).serialize(&mut encoder)?;
            }
            Some("ping") => {
                let Some(ip) = request
                    .get("ip")
                    .and_then(|value| serde_json::from_str::<String>(value.get()).ok())
                else {
                    return Ok(());
                };
                if ip.is_empty() {
                    return Ok(());
                }
                log("INFO", format_args!("ping request: {ip}"));
                ip.parse::<IpAddr>().map_err(io::Error::other)?;
                let mut result = run_ping(&ip);
                result.version = Some(VERSION);
                result.serialize(&mut encoder)?;
            }
            _ => {
                log("WARNING", "unknown command");
                serde_json::json!({"error": "unknown command"}).serialize(&mut encoder)?;
            }
        }
        let signature = self
            .mac(b"\x01", ts, nonce, &payload)
            .finalize()
            .into_bytes();
        header[..32].copy_from_slice(&signature);
        header[72..74].copy_from_slice(&(payload.len() as u16).to_be_bytes());
        let mut response = header.to_vec();
        response.extend_from_slice(&payload);
        let mut remaining = response.as_slice();
        let deadline = Instant::now() + CONN_TIMEOUT;
        while !remaining.is_empty() {
            let timeout = deadline.saturating_duration_since(Instant::now());
            if timeout.is_zero() {
                return Err(io::ErrorKind::TimedOut.into());
            }
            conn.set_write_timeout(Some(timeout))?;
            match conn.write(remaining) {
                Ok(0) => return Err(io::ErrorKind::WriteZero.into()),
                Ok(n) => remaining = &remaining[n..],
                Err(error) if error.kind() == io::ErrorKind::Interrupted => continue,
                Err(error) => return Err(error),
            }
        }
        Ok(())
    }
}

fn recv_exact(conn: &mut TcpStream, mut buffer: &mut [u8], deadline: Instant) -> io::Result<()> {
    while !buffer.is_empty() {
        let remaining = deadline.saturating_duration_since(Instant::now());
        if remaining.is_zero() {
            return Err(io::Error::new(
                io::ErrorKind::TimedOut,
                "read deadline exceeded",
            ));
        }
        conn.set_read_timeout(Some(remaining))?;
        match conn.read(buffer) {
            Ok(0) => return Err(io::ErrorKind::UnexpectedEof.into()),
            Ok(n) => buffer = &mut buffer[n..],
            Err(error) if error.kind() == io::ErrorKind::Interrupted => continue,
            Err(error) => return Err(error),
        }
    }
    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let port: u16 = env::var("LISTEN_PORT")
        .unwrap_or_else(|_| "9000".into())
        .trim()
        .parse()?;
    let raw_key = match env::var("SECRET_KEY_FILE") {
        Ok(file) if !file.is_empty() => fs::read_to_string(file)?.trim().to_owned(),
        _ => env::var("SECRET_KEY").unwrap_or_default(),
    };
    if raw_key.is_empty() {
        return Err("SECRET_KEY or SECRET_KEY_FILE not set".into());
    }
    // bytes.fromhex allows ASCII whitespace between bytes, but not between nibbles.
    let mut bytes = raw_key.bytes();
    let mut key = Vec::new();
    while let Some(high) = bytes.next() {
        if high.is_ascii_whitespace() || high == b'\x0b' {
            continue;
        }
        let low = bytes.next().ok_or("invalid secret key")?;
        let high = (high as char).to_digit(16).ok_or("invalid secret key")?;
        let low = (low as char).to_digit(16).ok_or("invalid secret key")?;
        key.push((high * 16 + low) as u8);
    }
    let agent = Agent {
        key: key.try_into().map_err(|_| "invalid secret key length")?,
        nonces: Mutex::new(HashMap::new()),
    };
    log("INFO", "Running self-test");
    let mut healthy = false;
    for ip in ["127.0.0.1", "::1"] {
        let result = run_ping(ip);
        if result.reachable && result.latency.is_some() && result.recv == 4 {
            log("INFO", format_args!("Self-test OK ({ip}): {result:?}"));
            healthy = true;
            break;
        }
        log(
            "WARNING",
            format_args!("Self-test via {ip} failed: {result:?}"),
        );
    }
    if !healthy {
        return Err("Self-test FAILED (ping binary missing or lacking ICMP permission?)".into());
    }
    let socket = Socket::new(Domain::IPV6, Type::STREAM, Some(Protocol::TCP))?;
    socket.set_reuse_address(true)?;
    let _ = socket.set_only_v6(false);
    socket.bind(&SocketAddr::new(Ipv6Addr::UNSPECIFIED.into(), port).into())?;
    socket.listen(6)?;
    let listener: TcpListener = socket.into();
    log(
        "INFO",
        format_args!("DN42 Peer Finder Agent v{VERSION} listening on port {port}"),
    );
    // Eight blocking accept loops bound active connections without accepting a ninth.
    thread::scope(|scope| {
        for _ in 0..MAX_WORKERS {
            scope.spawn(|| {
                loop {
                    match listener.accept() {
                        Ok((mut conn, _)) => {
                            if let Err(error) = agent.handle(&mut conn)
                                && !matches!(
                                    error.kind(),
                                    io::ErrorKind::TimedOut
                                        | io::ErrorKind::WouldBlock
                                        | io::ErrorKind::UnexpectedEof
                                )
                            {
                                log("ERROR", format_args!("handler error: {error}"));
                            }
                        }
                        Err(_) => thread::sleep(Duration::from_secs(1)),
                    }
                }
            });
        }
    });
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn python_json_extensions_do_not_change_string_escapes() {
        let value = decode_request(
            br#"{"ignored":[NaN,Infinity,-Infinity,"\ud800","\udc00"],"command":"version"}"#,
        )
        .unwrap();
        assert_eq!(value["command"].get(), "\"version\"");
        let value = decode_request(br#"{"command":"\\ud800 NaN Infinity \""}"#).unwrap();
        assert_eq!(
            serde_json::from_str::<String>(value["command"].get()).unwrap(),
            "\\ud800 NaN Infinity \""
        );
        assert!(decode_request(br#"{"command":NaNfoo}"#).is_err());
        assert!(decode_request(br#"{"command":"\uxxxx"}"#).is_err());
    }

    #[test]
    fn parse_empty_and_loss() {
        let result = parse_ping_output("");
        assert!(!result.reachable);
        assert_eq!(result.sent, 0);
        assert!(result.latency.is_none());
        let result = parse_ping_output("4 packets transmitted, 0 received");
        assert_eq!(result.sent, 4);
        assert!(!result.reachable);
    }

    #[test]
    fn parse_packet_and_rtt_variants() {
        for received in ["2 received", "2 packets received"] {
            for stats in ["rtt min/avg/max/mdev", "round-trip min/avg/max/stddev"] {
                let result = parse_ping_output(&format!(
                    "4 packets transmitted, {received}\n{stats} = 1.0/2.0/3.0/0.1 ms"
                ));
                assert!(result.reachable);
                assert_eq!((result.sent, result.recv), (4, 2));
                assert_eq!(result.min_rtt, Some(1.0));
                assert_eq!(result.latency, Some(2.0));
                assert_eq!(result.max_rtt, Some(3.0));
                assert_eq!(result.jitter, Some(0.1));
            }
        }
    }
}
