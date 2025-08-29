#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p gitMinimal
# shellcheck shell=bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

for F in as_del_list ip6_del_list ip_del_list new_gtlds_list nic_handles_list tld_serv_list; do
    wget "https://github.com/rfc1036/whois/raw/refs/heads/next/$F" -O "$SCRIPT_DIR/$F"
done
