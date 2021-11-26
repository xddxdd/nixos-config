#!/bin/sh
CURR_DIR=$(pwd)

TEMP_DIR=$(mktemp -d /tmp/dns.XXXXXXXX)
nix eval --raw ".#dnsRecords" > "$TEMP_DIR/dnsconfig.js" --show-trace
nix run "nixpkgs#age" -- -i "$HOME/.ssh/id_ed25519" --decrypt -o "$TEMP_DIR/creds.json" "secrets/dnscontrol.age"
mkdir -p "$TEMP_DIR/zones"

cd "$TEMP_DIR" && nix run "nixpkgs#dnscontrol" -- "$1"
RET=$?
rm -rf "$CURR_DIR/zones"
mv "$TEMP_DIR/zones" "$CURR_DIR/zones"

rm -rf "$TEMP_DIR"
exit $RET
