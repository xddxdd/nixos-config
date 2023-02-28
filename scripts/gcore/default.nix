{
  pkgs,
  lib,
  LT,
  inputs,
  ...
} @ args: let
  py = pkgs.python3.withPackages (p: with p; [requests]);

  script = ./gcore.py;

  # This is safe to share
  uptimerobotReadonlyKey = "ur337210-25e109e659057315e5e00a49";

  records = pkgs.writeText "gcore.json" (builtins.toJSON (lib.mapAttrsToList
    (k: v: {
      name = "${k}.lantian.pub";
      A = lib.optionals (v.public.IPv4 != "") [
        v.public.IPv4
      ];
      # AAAA record
      AAAA =
        lib.optionals (v.public.IPv6 != "") [
          v.public.IPv6
        ]
        ++ lib.optionals (v.public.IPv6Alt or "" != "") [
          v.public.IPv6Alt
        ];
      CNAME = ["${k}.lantian.pub"];
      inherit (v.city) lat lng;
    })
    LT.serverHosts));
in ''
  CURR_DIR=$(pwd)
  TEMP_DIR=$(mktemp -d /tmp/dns.XXXXXXXX)
  ${pkgs.age}/bin/age \
    -i "$HOME/.ssh/id_ed25519" \
    --decrypt -o "$TEMP_DIR/creds.json" \
    "${inputs.secrets}/dnscontrol.age"
  cd "$TEMP_DIR"

  ${py}/bin/python ${script} \
    "${uptimerobotReadonlyKey}" \
    "${records}"
  RET=$?

  GCORE_API_KEY=$(cat creds.json | jq -r ".gcore.\"api-key\"")
  DNS_TARGET=56631131.xyz/geo-test.56631131.xyz

  # ${pkgs.curl}/bin/curl \
  #   -X POST \
  #   -H "Authorization: APIKey $GCORE_API_KEY" \
  #   -H "Content-Type: application/json" \
  #   -d "@a.json" \
  #   https://api.gcorelabs.com/dns/v2/zones/56631131.xyz/$DNS_TARGET/A

  # ${pkgs.curl}/bin/curl \
  #   -X POST \
  #   -H "Authorization: APIKey $GCORE_API_KEY" \
  #   -H "Content-Type: application/json" \
  #   -d "@a.json" \
  #   https://api.gcorelabs.com/dns/v2/zones/56631131.xyz/$DNS_TARGET/AAAA

  # ${pkgs.curl}/bin/curl \
  #   -X POST \
  #   -H "Authorization: APIKey $GCORE_API_KEY" \
  #   -H "Content-Type: application/json" \
  #   -d "@a.json" \
  #   https://api.gcorelabs.com/dns/v2/zones/56631131.xyz/$DNS_TARGET/CNAME

  cd "$CURR_DIR"
  rm -rf "$TEMP_DIR"
  exit $RET
''
