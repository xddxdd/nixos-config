{
  pkgs,
  inputs,
  age,
  ...
}:
let
  # inherit (pkgs) dnscontrol;
  dnscontrol = pkgs.buildGoModule rec {
    pname = "dnscontrol";
    version = "2b7756e51f0f3eac95af286fa19094f58554ec32";

    src = pkgs.fetchFromGitHub {
      owner = "xddxdd";
      repo = "dnscontrol";
      rev = version;
      sha256 = "sha256-50J89sELkSEgyzk1SUDMN6xsXwm7K2ZDidBg0/TaZMg=";
    };

    vendorHash = "sha256-6ePEgHVFPtkW+C57+cPLj5yc9YaCRKrnBFo2Y1pcglM=";

    ldflags = [
      "-s"
      "-w"
    ];

    preCheck = ''
      # requires network
      rm pkg/spflib/flatten_test.go pkg/spflib/parse_test.go
    '';
  };
in
''
  set -euxo pipefail

  CURR_DIR="$(pwd)"

  TEMP_DIR="$(mktemp -d /tmp/dns.XXXXXXXX)"
  nix build .#dnscontrol-config -o "$TEMP_DIR/dnsconfig.js"

  ${age}/bin/age \
    -i "$HOME/.ssh/id_ed25519" \
    --decrypt -o "$TEMP_DIR/creds.json" \
    "${inputs.secrets}/dnscontrol.age"
  mkdir -p "$TEMP_DIR/zones"

  cd "$TEMP_DIR"
  ${dnscontrol}/bin/dnscontrol $* && RET=0 || RET=$?
  rm -rf "$CURR_DIR/zones"
  mv "$TEMP_DIR/zones" "$CURR_DIR/zones"

  cd "$CURR_DIR"
  rm -rf "$TEMP_DIR"
  exit $RET
''
