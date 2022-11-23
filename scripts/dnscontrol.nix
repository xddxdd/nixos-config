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
    version = "3af61f2cd4ad9929ed21cadac7787edc56e67018";

    src = fetchFromGitHub {
      owner = "xddxdd";
      repo = "dnscontrol";
      rev = version;
      sha256 = "sha256-Fzb383JfQ2VaIJR0Un3PQ35z7Bjh0aTyHMCZxEQ6lqw=";
    };

    vendorSha256 = "sha256-f6O5JcaDVtpp9RRzAYVqefeVpw0sHRSbvLSry79mvMI=";

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
