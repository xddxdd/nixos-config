#!/usr/bin/env python3
import json
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

import requests

FLAPALERTED_INSTANCES = [
    "https://flapalerted.esd.cc",
    "https://dn42.leziblog.com/flapAlerted",
    "https://flapalerted.lantian.pub",
]


def fetch_flapping_prefixes(server: str) -> list[str]:
    try:
        url = f"{server.rstrip('/')}/flaps/active/compact"
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
        prefixes = [entry["Prefix"] for entry in data if "Prefix" in entry]
        return prefixes
    except (
        requests.exceptions.RequestException,
        json.JSONDecodeError,
        KeyError,
    ):
        return []


def main():
    all_prefixes: set[str] = set()

    max_workers = len(FLAPALERTED_INSTANCES)
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_server = {
            executor.submit(fetch_flapping_prefixes, server): server
            for server in FLAPALERTED_INSTANCES
        }

        for future in as_completed(future_to_server):
            prefixes = future.result()
            all_prefixes.update(prefixes)

    ipv4_prefixes = sorted([p for p in all_prefixes if ":" not in p])
    ipv6_prefixes = sorted([p for p in all_prefixes if ":" in p])

    with open(sys.argv[1], "w") as f:
        f.write("define FLAPPING_IPv4 = [" + ",".join(ipv4_prefixes) + "];\n")
        f.write("define FLAPPING_IPv6 = [" + ",".join(ipv6_prefixes) + "];\n")


if __name__ == "__main__":
    main()
