#!/usr/bin/env python3
import ipaddress
import re
import sys

import dns.resolver


def send_agi(command):
    sys.stdout.write(f"{command}\n")
    sys.stdout.flush()
    return sys.stdin.readline().strip()


def verify_enum(caller_id, real_ip_str):
    try:
        clean_ip = re.sub(r":\d+$", "", real_ip_str).strip("[]")
        real_ip = ipaddress.ip_address(clean_ip)
    except ValueError:
        return "ERROR_INVALID_IP"

    clean_number = re.sub(r"\D", "", caller_id)
    if not clean_number:
        return "ERROR_INVALID_NUMBER"
    enum_domain = ".".join(reversed(list(clean_number))) + ".e164.dn42"

    try:
        answers = dns.resolver.resolve(enum_domain, "NAPTR")
    except Exception:
        return "NO_ENUM_RECORD"

    for rdata in answers:
        regexp_match = re.search(r"!sip:.*?@(.*?)!", rdata.regexp.decode())
        if not regexp_match:
            continue

        raw_host_port = regexp_match.group(1).split(";")[0]
        clean_host = raw_host_port

        if raw_host_port.startswith("["):
            end_bracket = raw_host_port.find("]")
            if end_bracket != -1:
                clean_host = raw_host_port[1:end_bracket]
        else:
            if raw_host_port.count(":") == 1:
                clean_host = raw_host_port.split(":")[0]
            else:
                clean_host = raw_host_port

        try:
            target_ip = ipaddress.ip_address(clean_host)
            if real_ip == target_ip:
                return "PASS"
        except ValueError:
            try:
                try:
                    a_records = dns.resolver.resolve(clean_host, "A")
                    for a in a_records:
                        if real_ip == ipaddress.ip_address(a.to_text()):
                            return "PASS"
                except Exception:
                    pass

                try:
                    aaaa_records = dns.resolver.resolve(clean_host, "AAAA")
                    for aaaa in aaaa_records:
                        if real_ip == ipaddress.ip_address(aaaa.to_text()):
                            return "PASS"
                except Exception:
                    pass

            except Exception:
                continue

    return "SPOOFED"


if __name__ == "__main__":
    env = {}
    while True:
        line = sys.stdin.readline().strip()
        if not line:
            break
        key, _, value = line.partition(": ")
        env[key] = value

    caller_id = sys.argv[1] if len(sys.argv) > 1 else ""
    real_ip = sys.argv[2] if len(sys.argv) > 2 else ""

    result = verify_enum(caller_id, real_ip)

    send_agi(f'SET VARIABLE ENUM_VERIFY_RESULT "{result}"')
