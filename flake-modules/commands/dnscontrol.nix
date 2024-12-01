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
    version = "5abb8e355240ab5fa3d7dd1229ce92995565b499";

    src = pkgs.fetchFromGitHub {
      owner = "xddxdd";
      repo = "dnscontrol";
      rev = version;
      sha256 = "sha256-BmiZf5dfv1XOBYhxlDQsbtQWYDFl+30LRvb34HReCBA=";
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

  if [ -d "$CURR_DIR/zones" ]; then
    cp -r "$CURR_DIR/zones" "$TEMP_DIR/zones"
  fi

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
