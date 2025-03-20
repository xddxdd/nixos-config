{
  pkgs,
  lib,
  LT,
  ...
}:
let
  warp-cli-accept-tos =
    pkgs.runCommand "warp-cli-accept-tos" { nativeBuildInputs = [ pkgs.makeWrapper ]; }
      ''
        makeWrapper ${pkgs.cloudflare-warp}/bin/warp-cli $out/bin/warp-cli \
          --add-flags --accept-tos
      '';
in
{
  systemd.services.cloudflare-warp = {
    description = "Cloudflare Warp";
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      (lib.hiPrio warp-cli-accept-tos)
      pkgs.cloudflare-warp
    ];

    script = ''
      exec ${pkgs.cloudflare-warp}/bin/warp-svc >/dev/null 2>&1
    '';

    postStart = ''
      while ! warp-cli status; do
        echo "Waiting for warp-svc to be ready"
        sleep 5
      done

      warp-cli registration show || warp-cli registration new
      warp-cli mode proxy
      warp-cli proxy port ${LT.portStr.CloudflareWarp}
      warp-cli connect
    '';

    environment = {
      RUST_BACKTRACE = "1";
      HOME = "/var/lib/cloudflare-warp";
    };

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_PTRACE"
        "CAP_DAC_READ_SEARCH"
        "CAP_NET_RAW"
        "CAP_SETUID"
        "CAP_SETGID"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_PTRACE"
        "CAP_DAC_READ_SEARCH"
        "CAP_NET_RAW"
        "CAP_SETUID"
        "CAP_SETGID"
      ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];

      User = "cloudflare-warp";
      Group = "cloudflare-warp";

      StateDirectory = "cloudflare-warp";
      RuntimeDirectory = "cloudflare-warp";
      LogsDirectory = "cloudflare-warp";
    };
  };

  users.users.cloudflare-warp = {
    group = "cloudflare-warp";
    isSystemUser = true;
  };
  users.groups.cloudflare-warp = { };
}
