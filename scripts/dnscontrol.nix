{ pkgs
, lib
, inputs
, writeText
, callPackage
, buildGoModule
, fetchFromGitHub
, age
, ...
}@args:

let
  dnsRecords = writeText "dnsconfig.js" (callPackage ../dns args);

  dnscontrol = buildGoModule rec {
    pname = "dnscontrol";
    version = "2f76fa1240feffaff551c7f546552ad0269efaac";

    src = fetchFromGitHub {
      owner = "xddxdd";
      repo = "dnscontrol";
      rev = version;
      sha256 = "sha256-jgvN7LlTM+vTiuQSzjmWEXJ8tMXZxbrNoHTwH1/Q3U4=";
    };

    vendorSha256 = "sha256-BixsHrfkM0RaYoTDxmmq5ytX4GPSQu/kj/3KiGpSJ4A=";

    ldflags = [ "-s" "-w" ];

    preCheck = ''
      # requires network
      rm pkg/spflib/flatten_test.go pkg/spflib/parse_test.go
    '';
  };
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
