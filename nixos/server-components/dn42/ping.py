#!/usr/bin/env python3
import json
import logging
import re
import subprocess
import sys

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stderr)],
)


with open("/etc/dn42.json") as f:
    peers = json.load(f)

results = {}
for name, cfg in peers.items():
    tunnel = cfg.get("tunnel") or {}
    addressing = cfg.get("addressing") or {}
    remote_address = tunnel.get("remoteAddress")
    peer_ipv4 = addressing.get("peerIPv4")
    peer_ipv6 = addressing.get("peerIPv6")
    peer_ipv6_linklocal = addressing.get("peerIPv6LinkLocal")
    interface = f"dn42-{name}"

    targets = []
    if peer_ipv6_linklocal:
        targets.append(("linklocal", peer_ipv6_linklocal))
    if peer_ipv4:
        targets.append(("ipv4", peer_ipv4))
    if peer_ipv6:
        targets.append(("ipv6", peer_ipv6))
    if remote_address:
        targets.append(("remote", remote_address))

    logging.info(f"{name=} {targets=}")

    latency = None
    for ttype, addr in targets:
        cmd = ["ping", "-n", "-c", "5"]
        if ttype == "linklocal":
            cmd.extend(["-I", interface])
        cmd.append(addr)
        logging.info(f"{cmd=}")
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            m = re.search(
                r"rtt min/avg/max/mdev = (\d+\.?\d*)/(\d+\.?\d*)/(\d+\.?\d*)/(\d+\.?\d*) ms",
                r.stdout,
            )
            if m:
                latency = round(float(m.group(2)))
                logging.info(f"{name=} {addr=} {latency=}")
                break
        except Exception:
            pass

    results[name] = latency

print(json.dumps(results, indent=2, sort_keys=True))
