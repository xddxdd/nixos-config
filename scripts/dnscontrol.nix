{
  pkgs,
  lib,
  inputs,
  writeText,
  callPackage,
  buildGoModule,
  fetchFromGitHub,
  age,
  ...
} @ args: let
  dnscontrol = pkgs.dnscontrol;
in ''
  set -euo pipefail

  CURR_DIR=$(pwd)

  TEMP_DIR=$(mktemp -d /tmp/dns.XXXXXXXX)

  if [[ -e $TEMP_DIR/dnsconfig.js ]]; then rm -f $TEMP_DIR/dnsconfig.js; fi
  nix build .#dnscontrol-config
  cat result > $TEMP_DIR/dnsconfig.js

  ${age}/bin/age \
    -i "$HOME/.ssh/id_ed25519" \
    --decrypt -o "$TEMP_DIR/creds.json" \
    "${inputs.secrets}/dnscontrol.age"
  mkdir -p "$TEMP_DIR/zones"

  cd "$TEMP_DIR"
  ${dnscontrol}/bin/dnscontrol --diff2 $*
  RET=$?
  rm -rf "$CURR_DIR/zones"
  mv "$TEMP_DIR/zones" "$CURR_DIR/zones"

  cd "$CURR_DIR"
  rm -rf "$TEMP_DIR"
  exit $RET
''
