#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.requests
import os
import socket

import requests
import urllib3.util.connection as urllib_conn

API_BASE = "https://api.bunny.net"
ZONE_DOMAIN = "xuyh0120.win"
RRSET_NAME = "home-ddns"
TTL = 60

RECORD_TYPES = {
    "A": 0,
    "AAAA": 1,
}


def get_current_ip(ip_type: str) -> str | None:
    """Get current public IP address, forcing specific IP version."""
    original_family = urllib_conn.allowed_gai_family
    try:
        if ip_type == "ipv4":
            urllib_conn.allowed_gai_family = lambda: socket.AF_INET
        elif ip_type == "ipv6":
            urllib_conn.allowed_gai_family = lambda: socket.AF_INET6
        else:
            return None

        resp = requests.get("https://ifconfig.me", timeout=10)
        return resp.text.strip() if resp.status_code == 200 else None
    except requests.RequestException:
        pass
    finally:
        urllib_conn.allowed_gai_family = original_family
    return None


def get_zone_id(api_key: str) -> int | None:
    """Find DNS zone ID by domain name via Bunny API."""
    url = f"{API_BASE}/dnszone"
    headers = {"AccessKey": api_key}
    params = {"search": ZONE_DOMAIN}

    try:
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        if resp.status_code != 200:
            print(f"[FAIL] Could not list DNS zones: {resp.status_code} - {resp.text}")
            return None
        for zone in resp.json().get("Items", []):
            if zone.get("Domain") == ZONE_DOMAIN:
                return zone["Id"]
        print(f"[FAIL] Zone {ZONE_DOMAIN} not found in account")
        return None
    except requests.RequestException as e:
        print(f"[ERROR] Listing DNS zones failed: {e}")
        return None


def find_record_id(api_key: str, zone_id: int, record_type: int) -> int | None:
    """Find existing DNS record ID by name and type."""
    url = f"{API_BASE}/dnszone/{zone_id}"
    headers = {"AccessKey": api_key}

    try:
        resp = requests.get(url, headers=headers, timeout=30)
        if resp.status_code != 200:
            return None
        for record in resp.json().get("Records", []):
            if record.get("Type") == record_type and record.get("Name") == RRSET_NAME:
                return record["Id"]
        return None
    except requests.RequestException:
        return None


def upsert_record(
    api_key: str, zone_id: int, record_type_name: str, ip_address: str
) -> bool:
    """Create or update a DNS record via Bunny API."""
    record_type = RECORD_TYPES[record_type_name]
    headers = {"AccessKey": api_key, "Content-Type": "application/json"}
    payload = {
        "Type": record_type,
        "Ttl": TTL,
        "Value": ip_address,
        "Name": RRSET_NAME,
    }

    existing_id = find_record_id(api_key, zone_id, record_type)

    try:
        if existing_id is not None:
            url = f"{API_BASE}/dnszone/{zone_id}/records/{existing_id}"
            payload["Id"] = existing_id
            resp = requests.post(url, json=payload, headers=headers, timeout=30)
        else:
            url = f"{API_BASE}/dnszone/{zone_id}/records"
            resp = requests.put(url, json=payload, headers=headers, timeout=30)

        if resp.status_code in (200, 201, 204):
            action = "updated" if existing_id is not None else "created"
            print(f"[OK] {record_type_name} record {action}: {ip_address}")
            return True
        else:
            print(
                f"[FAIL] {record_type_name} upsert failed: {resp.status_code} - {resp.text}"
            )
            return False
    except requests.RequestException as e:
        print(f"[ERROR] {record_type_name} upsert error: {e}")
        return False


def main():
    api_key = os.environ.get("BUNNY_API_KEY")
    if not api_key:
        print("Error: BUNNY_API_KEY environment variable not set")
        return 1

    zone_id = get_zone_id(api_key)
    if zone_id is None:
        return 1

    ipv4 = get_current_ip("ipv4")
    ipv6 = get_current_ip("ipv6")

    if not ipv4 and not ipv6:
        print("Error: Could not determine public IP address")
        return 1

    success = True
    if ipv4:
        if not upsert_record(api_key, zone_id, "A", ipv4):
            success = False

    if ipv6:
        if not upsert_record(api_key, zone_id, "AAAA", ipv6):
            success = False

    return 0 if success else 1


if __name__ == "__main__":
    exit(main())
