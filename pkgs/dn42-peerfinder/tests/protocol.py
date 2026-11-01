#!/usr/bin/env python3
"""Developer-only differential harness; all ping executions use a local fixture.

Run first with: python3 tests/protocol.py --agent python3 /path/to/pinned-agent.py
Then with:     python3 tests/protocol.py --agent /tmp/target/debug/dn42-peerfinder
Reference: official 1.2.0, sha256-nL4sIU3EQmKiTyGV+ljk4erz7ihYTsWkO0WlCzeKVV4=
"""

import argparse
import hmac
import json
import os
import secrets
import socket
import struct
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

HEADER = struct.Struct(">32s8s32sH")
KEY = bytes(range(32))
SUCCESS = {
    "reachable": True,
    "sent": 4,
    "recv": 4,
    "latency": 2.0,
    "jitter": 0.1,
    "min_rtt": 1.0,
    "max_rtt": 3.0,
    "version": "1.2.0",
}
FAILURE = {
    "reachable": False,
    "sent": 0,
    "recv": 0,
    "latency": None,
    "jitter": None,
    "min_rtt": None,
    "max_rtt": None,
    "version": "1.2.0",
}
PING = r"""
import json, os, sys, time
from pathlib import Path
root = Path(__file__).parent
with (root / "calls").open("a") as log:
    log.write(json.dumps({"args": sys.argv[1:], "env": dict(os.environ)}) + "\n")
modes = json.loads((root / "modes").read_text())
mode = modes.get(sys.argv[-1], "success")
if mode == "sleep":
    time.sleep(11)
if mode == "empty" or mode == "sleep":
    sys.exit(1)
if mode == "invalid-utf8":
    sys.stdout.buffer.write(b"\xff")
    sys.exit(0)
if mode == "stderr":
    print("4 packets transmitted, 4 received", file=sys.stderr)
    sys.exit(1)
if mode == "loss":
    print("4 packets transmitted, 0 received, 100% packet loss")
    sys.exit(1)
if mode == "packets":
    print("4 packets transmitted, 2 packets received")
    print("round-trip min/avg/max/stddev = 1.0/2.0/3.0/0.1 ms")
    sys.exit(1)
if mode == "rtt":
    print("rtt min/avg/max/mdev = 1.0/2.0/3.0/0.1 ms")
    sys.exit(0)
print("4 packets transmitted, 4 received, 0% packet loss, time 3000ms")
print("rtt min/avg/max/mdev = 1.0/2.0/3.0/0.1 ms")
"""


def frame(body, *, ts=None, nonce=None, marker=b"\x00", length=None):
    if not isinstance(body, bytes):
        body = json.dumps(body).encode()
    ts = struct.pack(">Q", int(time.time()) if ts is None else ts)
    nonce = secrets.token_bytes(32) if nonce is None else nonce
    sig = hmac.digest(KEY, marker + ts + nonce + body, "sha256")
    return HEADER.pack(sig, ts, nonce, len(body) if length is None else length) + body


class Agent:
    def __init__(self, modes=None, extra_env=None):
        self.tmp = tempfile.TemporaryDirectory(prefix="peerfinder-protocol-")
        self.root = Path(self.tmp.name)
        ping = self.root / "ping"
        ping.write_text(f"#!{sys.executable}\n" + PING)
        ping.chmod(0o755)
        self.set_modes(modes or {})
        with socket.socket(socket.AF_INET6) as sock:
            sock.bind(("::1", 0))
            self.port = sock.getsockname()[1]
        env = dict(
            os.environ,
            PATH=str(self.root),
            SECRET_KEY=KEY.hex(),
            LISTEN_PORT=str(self.port),
            LOG_LEVEL="DEBUG",
        )
        env.pop("SECRET_KEY_FILE", None)
        env.update(extra_env or {})
        for key, value in list(env.items()):
            if value is None:
                del env[key]
        self.log = (self.root / "log").open("w+")
        self.proc = subprocess.Popen(COMMAND, env=env, stdout=self.log, stderr=self.log)

    def set_modes(self, modes):
        (self.root / "modes").write_text(json.dumps(modes))

    def ready(self):
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if self.proc.poll() is not None:
                self.log.seek(0)
                raise AssertionError(self.log.read())
            try:
                self.connect().close()
                return self
            except OSError:
                time.sleep(0.02)
        raise AssertionError("agent did not listen")

    def connect(self, host="::1"):
        sock = socket.create_connection((host, self.port), timeout=4)
        sock.settimeout(4)
        return sock

    def calls(self):
        return [
            json.loads(line) for line in (self.root / "calls").read_text().splitlines()
        ]

    def close(self):
        if self.proc.poll() is None:
            self.proc.terminate()
        self.proc.wait(timeout=5)
        self.log.close()
        self.tmp.cleanup()


def receive(sock):
    result = b""
    try:
        while True:
            data = sock.recv(8192)
            if not data:
                return result
            result += data
    except ConnectionResetError:
        return result


class Protocol(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.agent = Agent()
        cls.addClassCleanup(cls.agent.close)
        cls.agent.ready()

    def exchange(self, request, *, agent=None, host="::1"):
        with (agent or self.agent).connect(host) as sock:
            sock.sendall(request)
            return receive(sock)

    def assert_reply(self, response, request, expected):
        self.assertGreaterEqual(len(response), HEADER.size)
        sig, ts, nonce, length = HEADER.unpack(response[: HEADER.size])
        payload = response[HEADER.size :]
        self.assertEqual((ts, nonce), (request[32:40], request[40:72]))
        self.assertEqual(length, len(payload))
        self.assertEqual(payload, json.dumps(expected).encode())
        self.assertEqual(
            sig, hmac.digest(KEY, b"\x01" + ts + nonce + payload, "sha256")
        )

    def test_version_and_legacy_ipv4_ipv6(self):
        for marker in (b"\x00", b""):
            for host in ("127.0.0.1", "::1"):
                with self.subTest(marker=marker, host=host):
                    request = frame({"command": "version"}, marker=marker)
                    self.assert_reply(
                        self.exchange(request, host=host), request, {"version": "1.2.0"}
                    )

    def test_hmac_rejections(self):
        valid = frame({"command": "version"})
        for request in (
            bytes([valid[0] ^ 1]) + valid[1:],
            valid[:-1] + b"!",
            frame({"command": "version"}, marker=b"\x01"),
            valid[:32] + bytes([valid[32] ^ 1]) + valid[33:],
            valid[:40] + bytes([valid[40] ^ 1]) + valid[41:],
        ):
            with self.subTest(request=request.hex()):
                self.assertEqual(self.exchange(request), b"")

    def test_timestamp_window(self):
        for delta in (-31, 31, -29, 29):
            with self.subTest(delta=delta):
                request = frame({"command": "version"}, ts=int(time.time()) + delta)
                response = self.exchange(request)
                if abs(delta) > 30:
                    self.assertEqual(response, b"")
                else:
                    self.assert_reply(response, request, {"version": "1.2.0"})
        for ts in (0, 2**64 - 1):
            self.assertEqual(self.exchange(frame({"command": "version"}, ts=ts)), b"")

    def test_replay_and_expiry(self):
        nonce = secrets.token_bytes(32)
        request = frame({"command": "version"}, nonce=nonce, ts=int(time.time()) - 29)
        self.assert_reply(self.exchange(request), request, {"version": "1.2.0"})
        self.assertEqual(self.exchange(frame({"command": "version"}, nonce=nonce)), b"")
        time.sleep(2.1)
        request = frame({"command": "version"}, nonce=nonce)
        self.assert_reply(self.exchange(request), request, {"version": "1.2.0"})
        self.assertEqual(self.exchange(request), b"")

    def test_bad_auth_does_not_consume_nonce(self):
        request = frame({"command": "version"})
        self.assertEqual(self.exchange(bytes(32) + request[32:]), b"")
        self.assert_reply(self.exchange(request), request, {"version": "1.2.0"})

    def test_invalid_json_consumes_nonce(self):
        nonce = secrets.token_bytes(32)
        self.assertEqual(self.exchange(frame(b"{", nonce=nonce)), b"")
        self.assertEqual(self.exchange(frame({"command": "version"}, nonce=nonce)), b"")

    def test_invalid_requests(self):
        for body in (
            b"",
            b"{",
            b"\xff",
            b"{}junk",
            b"\xef\xbb\xbf{}",
            b"[]",
            b"null",
            b"1",
            b'"version"',
            b'{"command":"version","ignored":"\xff"}',
        ):
            with self.subTest(body=body):
                self.assertEqual(self.exchange(frame(body)), b"")
        for ip in (
            None,
            "",
            False,
            0,
            [],
            {},
            "localhost",
            "127.1",
            "::1%lo",
            "127.0.0.1;true",
            "-V",
            "999.0.0.1",
            "::g",
            1,
            ["::1"],
        ):
            with self.subTest(ip=ip):
                self.assertEqual(
                    self.exchange(frame({"command": "ping", "ip": ip})), b""
                )
        self.assertEqual(self.exchange(frame({"command": "ping"})), b"")

    def test_json_edge_cases(self):
        for body in (
            b'{"command":"ping","command":"version"}',
            b'{"command":"version","ignored":NaN}',
            b'{"command":"version","ignored":Infinity}',
            b'{"command":"version","ignored":-Infinity}',
            b'{"command":"version","ignored":1e9999}',
            b'{"$serde_json::private::Number":"not-a-number","command":"version"}',
            b'{"command":"version","ignored":{"$serde_json::private::Number":"not-a-number"}}',
            b'{"command":"version","ignored":"\\ud800"}',
            b'{"command":"version","ignored":"\\udc00"}',
            b'{"command":"version","ignored":"\\ud800\\udc00"}',
            b'{"command":"version","ignored":' + b"[" * 200 + b"0" + b"]" * 200 + b"}",
        ):
            with self.subTest(body=body[:100]):
                request = frame(body)
                self.assert_reply(self.exchange(request), request, {"version": "1.2.0"})
        for value in (
            b"NaN",
            b"Infinity",
            b"-Infinity",
            b'"\\ud800"',
            b"1e9999",
            b"9" * 1000,
        ):
            with self.subTest(command=value):
                request = frame(b'{"command":' + value + b"}")
                self.assert_reply(
                    self.exchange(request), request, {"error": "unknown command"}
                )
                self.assertEqual(
                    self.exchange(frame(b'{"command":"ping","ip":' + value + b"}")), b""
                )

    def test_concurrent_replay(self):
        request = frame({"command": "version"})
        sockets = [self.agent.connect() for _ in range(8)]
        try:
            for sock in sockets:
                sock.sendall(request)
            responses = [receive(sock) for sock in sockets]
            self.assertEqual(sum(bool(response) for response in responses), 1)
            self.assert_reply(
                next(response for response in responses if response),
                request,
                {"version": "1.2.0"},
            )
        finally:
            for sock in sockets:
                sock.close()

    def test_unknown_commands(self):
        for command in (None, "", "VERSION", "bogus", 1, [], {}, True, "你好"):
            with self.subTest(command=command):
                request = frame({"command": command})
                self.assert_reply(
                    self.exchange(request), request, {"error": "unknown command"}
                )
        request = frame({})
        self.assert_reply(self.exchange(request), request, {"error": "unknown command"})

    def test_ping_output_and_environment(self):
        modes = {
            "192.0.2.1": "loss",
            "192.0.2.2": "empty",
            "192.0.2.3": "packets",
            "192.0.2.4": "rtt",
            "192.0.2.5": "stderr",
            "192.0.2.6": "invalid-utf8",
        }
        self.agent.set_modes(modes)
        try:
            for ip, expected in (
                ("::1", SUCCESS),
                ("127.0.0.1", SUCCESS),
                ("::ffff:192.0.2.9", SUCCESS),
                ("192.0.2.1", dict(FAILURE, sent=4)),
                ("192.0.2.2", FAILURE),
                ("192.0.2.3", dict(SUCCESS, recv=2)),
                ("192.0.2.4", dict(SUCCESS, reachable=False, sent=0, recv=0)),
                ("192.0.2.5", FAILURE),
                ("192.0.2.6", FAILURE),
            ):
                with self.subTest(ip=ip):
                    request = frame({"command": "ping", "ip": ip})
                    self.assert_reply(self.exchange(request), request, expected)
                    call = self.agent.calls()[-1]
                    self.assertEqual(
                        call["args"], ["-n", "-q", "-c", "4", "-w", "6", ip]
                    )
                    self.assertEqual(call["env"]["LANG"], "C")
                    self.assertEqual(call["env"]["LC_ALL"], "C")
                    # CPython can add PYTHONCOERCECLOCALE to the fixture itself.
                    self.assertLessEqual(
                        set(call["env"]),
                        {"LANG", "LC_ALL", "PATH", "PYTHONCOERCECLOCALE"},
                    )
        finally:
            self.agent.set_modes({})

    def test_ping_missing(self):
        agent = Agent()
        try:
            agent.ready()
            (agent.root / "ping").unlink()
            request = frame({"command": "ping", "ip": "::1"})
            self.assert_reply(self.exchange(request, agent=agent), request, FAILURE)
        finally:
            agent.close()

    def test_ping_timeout(self):
        self.agent.set_modes({"192.0.2.7": "sleep"})
        try:
            request = frame({"command": "ping", "ip": "192.0.2.7"})
            with self.agent.connect() as sock:
                sock.settimeout(12)
                start = time.monotonic()
                sock.sendall(request)
                response = receive(sock)
                elapsed = time.monotonic() - start
            self.assertGreater(elapsed, 9.8)
            self.assertLess(elapsed, 11.5)
            self.assert_reply(response, request, FAILURE)
        finally:
            self.agent.set_modes({})

    def test_body_limits(self):
        body = b'{"command":"version"}'
        request = frame(body + b" " * (2000 - len(body)))
        self.assert_reply(self.exchange(request), request, {"version": "1.2.0"})
        self.assertEqual(self.exchange(frame(body + b" " * (2001 - len(body)))), b"")
        self.assertEqual(self.exchange(frame(b"", length=65535)), b"")

    def test_fragmentation(self):
        request = frame({"command": "version"})
        with self.agent.connect() as sock:
            for byte in request:
                sock.sendall(bytes([byte]))
                time.sleep(0.001)
            self.assert_reply(receive(sock), request, {"version": "1.2.0"})

    def test_absolute_auth_deadline(self):
        for prefix in (
            b"",
            frame({"command": "version"})[:73],
            frame({"command": "version"})[:75],
        ):
            with self.subTest(length=len(prefix)), self.agent.connect() as sock:
                start = time.monotonic()
                if prefix:
                    sock.sendall(prefix)
                self.assertEqual(receive(sock), b"")
                self.assertGreater(time.monotonic() - start, 2.8)
                self.assertLess(time.monotonic() - start, 3.7)
        request = frame({"command": "version"})
        with self.agent.connect() as sock:
            start = time.monotonic()
            sock.sendall(request[:74])
            time.sleep(2)
            sock.sendall(request[74:75])
            self.assertEqual(receive(sock), b"")
            self.assertLess(time.monotonic() - start, 3.7)

    def test_partial_eof_and_one_request_per_connection(self):
        request = frame({"command": "version"})
        for length in (0, 1, 73, 74, 75):
            with self.subTest(length=length), self.agent.connect() as sock:
                sock.sendall(request[:length])
                sock.shutdown(socket.SHUT_WR)
                self.assertEqual(receive(sock), b"")
        request = frame({"command": "version"})
        self.assert_reply(
            self.exchange(request + frame({"command": "version"})),
            request,
            {"version": "1.2.0"},
        )

    def test_eight_workers(self):
        agent = Agent()
        sockets = []
        try:
            agent.ready()
            time.sleep(0.1)
            for _ in range(8):
                sock = agent.connect()
                sock.sendall(b"x")
                sockets.append(sock)
            time.sleep(0.15)
            with agent.connect() as queued:
                request = frame({"command": "version"})
                queued.sendall(request)
                queued.settimeout(0.3)
                with self.assertRaises(socket.timeout):
                    queued.recv(1)
                sockets.pop().close()
                queued.settimeout(2)
                self.assert_reply(receive(queued), request, {"version": "1.2.0"})
        finally:
            for sock in sockets:
                sock.close()
            agent.close()

    def test_startup_keys_and_selftest(self):
        for env in (
            {"SECRET_KEY": None},
            {"SECRET_KEY": "zz" * 32},
            {"SECRET_KEY": "ab" * 31},
            {"SECRET_KEY_FILE": "/nonexistent/dummy-secret"},
        ):
            with self.subTest(env=env):
                agent = Agent(extra_env=env)
                try:
                    self.assertNotEqual(agent.proc.wait(timeout=3), 0)
                    self.assertFalse((agent.root / "calls").exists())
                finally:
                    agent.close()
        agent = Agent(extra_env={"SECRET_KEY": "00 " * 32, "LOG_LEVEL": "not-a-level"})
        try:
            agent.ready()
        finally:
            agent.close()
        agent = Agent(modes={"127.0.0.1": "loss", "::1": "loss"})
        try:
            self.assertNotEqual(agent.proc.wait(timeout=3), 0)
            self.assertEqual(
                [c["args"][-1] for c in agent.calls()], ["127.0.0.1", "::1"]
            )
        finally:
            agent.close()
        agent = Agent(modes={"127.0.0.1": "loss"})
        try:
            agent.ready()
            self.assertEqual(
                [c["args"][-1] for c in agent.calls()], ["127.0.0.1", "::1"]
            )
        finally:
            agent.close()

    def test_credential_file_precedence(self):
        # A separate fixture directory avoids ever accessing a real credential.
        with tempfile.TemporaryDirectory(prefix="peerfinder-key-") as root:
            secret = Path(root) / "key"
            secret.write_text("\n " + KEY.hex() + " \n")
            agent = Agent(
                extra_env={"SECRET_KEY_FILE": str(secret), "SECRET_KEY": "invalid"}
            )
            try:
                agent.ready()
                request = frame({"command": "version"})
                self.assert_reply(
                    self.exchange(request, agent=agent), request, {"version": "1.2.0"}
                )
            finally:
                agent.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--agent", nargs=argparse.REMAINDER, required=True)
    args = parser.parse_args()
    COMMAND = args.agent
    unittest.main(argv=[sys.argv[0]], verbosity=2)
