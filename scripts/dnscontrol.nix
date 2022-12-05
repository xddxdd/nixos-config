{ pkgs
, lib
, inputs
, writeText
, callPackage
, buildGoModule
, fetchFromGitHub
, age
, dnscontrol
, ...
}@args:

let
  dnsRecords = writeText "dnsconfig.js" (callPackage ../dns args);
in
''
  CURR_DIR=$(pwd)

  TEMP_DIR=$(mktemp -d /tmp/dns.XXXXXXXX)
  cp ${dnsRecords} $TEMP_DIR/dnsconfig.js
  ${age}/bin/age \
    -i "$HOME/.ssh/id_ed25519" \
    --decrypt -o "$TEMP_DIR/creds.json" \
    "${inputs.secrets}/dnscontrol.age"
  mkdir -p "$TEMP_DIR/zones"

  cd "$TEMP_DIR"
  ${dnscontrol}/bin/dnscontrol $*
  RET=$?
  rm -rf "$CURR_DIR/zones"
  mv "$TEMP_DIR/zones" "$CURR_DIR/zones"

  cd "$CURR_DIR"
  rm -rf "$TEMP_DIR"
  exit $RET
''
