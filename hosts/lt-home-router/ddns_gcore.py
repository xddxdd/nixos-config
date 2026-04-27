#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.requests
import os
import socket

import requests
import urllib3.util.connection as urllib_conn

API_BASE = "https://api.gcore.com/dns/v2"
ZONE_NAME = "xuyh0120.win"
RRSET_NAME = "home-ddns.xuyh0120.win"
TTL = 60


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


def update_record(api_key: str, record_type: str, ip_address: str) -> bool:
    """Update DNS record via Gcore API."""
    url = f"{API_BASE}/zones/{ZONE_NAME}/{RRSET_NAME}/{record_type}"
    headers = {
        "Authorization": f"APIKey {api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "ttl": TTL,
        "resource_records": [
            {
                "content": [ip_address],
                "enabled": True,
            }
        ],
    }

    try:
        resp = requests.put(url, json=payload, headers=headers, timeout=30)
        if resp.status_code in (200, 201, 204):
            print(f"[OK] {record_type} record updated: {ip_address}")
            return True
        else:
            print(
                f"[FAIL] {record_type} update failed: {resp.status_code} - {resp.text}"
            )
            return False
    except requests.RequestException as e:
        print(f"[ERROR] {record_type} update error: {e}")
        return False


def main():
    api_key = os.environ.get("GCORE_API_KEY")
    if not api_key:
        print("Error: GCORE_API_KEY environment variable not set")
        return 1

    ipv4 = get_current_ip("ipv4")
    ipv6 = get_current_ip("ipv6")

    if not ipv4 and not ipv6:
        print("Error: Could not determine public IP address")
        return 1

    success = True
    if ipv4:
        if not update_record(api_key, "A", ipv4):
            success = False

    if ipv6:
        if not update_record(api_key, "AAAA", ipv6):
            success = False

    return 0 if success else 1


if __name__ == "__main__":
    exit(main())
