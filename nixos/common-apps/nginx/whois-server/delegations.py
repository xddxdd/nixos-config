#!/usr/bin/env python3
import ipaddress
import json
import re
import sys
from pathlib import Path

ABBREVIATIONS = {
    name: f"whois.{name}.net"
    for name in ("afrinic", "apnic", "arin", "lacnic", "ripe", "teredo", "twnic")
}


def server(value):
    value = value.lower()
    if value == "unknown":
        return None
    value = ABBREVIATIONS.get(value, value)
    if len(value) > 253 or not all(
        re.fullmatch(r"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?", label)
        for label in value.split(".")
    ):
        raise ValueError(f"Invalid WHOIS server: {value!r}")
    return value


def rows(name):
    for line in (resources / name).read_text(encoding="utf-8").splitlines():
        fields = line.split("#", 1)[0].split()
        if fields:
            yield fields


def asn(value):
    parts = value.split(".")
    if len(parts) not in (1, 2) or not all(
        re.fullmatch(r"\+?[0-9]+", part) for part in parts
    ):
        raise ValueError(f"Invalid ASN: {value!r}")
    numbers = list(map(int, parts))
    if max(numbers) > 4294967295:
        raise ValueError(f"ASN component out of range: {value!r}")
    number = numbers[0] if len(numbers) == 1 else numbers[0] * 65536 + numbers[1]
    if number > 4294967295:
        raise ValueError(f"ASN out of range: {value!r}")
    return number


resources = Path(sys.argv[1])
data = {key: [] for key in ("asn", "ipv4", "ipv6", "handle", "domain")}
for line in (resources / "as_del_list").read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    fields = line.split("\t")
    if len(fields) != 3:
        continue
    lo, hi, host = fields
    try:
        lo, hi = asn(lo), asn(hi)
    except ValueError:
        continue
    data["asn"].append([lo, hi, server(host)])

for key, filename, version in (
    ("ipv4", "ip_del_list", 4),
    ("ipv6", "ip6_del_list", 6),
):
    for cidr, host in rows(filename):
        network = ipaddress.ip_network(cidr, strict=False)
        if network.version != version:
            raise ValueError(f"Wrong address family in {filename}: {cidr}")
        data[key].append(
            [str(int(network.network_address)), network.prefixlen, server(host)]
        )
    data[key].sort(key=lambda row: -row[1])

for line in (resources / "nic_handles_list").read_text(encoding="utf-8").splitlines():
    suffix, separator, host = line.partition("\t")
    if separator:
        data["handle"].append([suffix.lstrip("-").lower(), server(host.strip())])

for fields in rows("tld_serv_list"):
    suffix, kind, *rest = fields
    if kind in ("NONE", "WEB", "ARPA", "IP6"):
        continue
    if kind in ("RECURSIVE", "VERISIGN"):
        if not rest:
            raise ValueError(f"Missing WHOIS server: {fields!r}")
        host = rest[-1]
    else:
        if rest:
            raise ValueError(f"Unexpected WHOIS fields: {fields!r}")
        host = kind
    data["domain"].append([suffix.lower(), server(host)])
for (suffix,) in rows("new_gtlds_list"):
    suffix = suffix.lower()
    data["domain"].append([f".{suffix}", server(f"whois.nic.{suffix}")])
data["domain"].sort(key=lambda row: -len(row[0]))
print("export default " + json.dumps(data, separators=(",", ":")) + ";")
