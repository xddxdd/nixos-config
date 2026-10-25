{
  pkgs,
  config,
  LT,
  lib,
  utils,
  ...
}:
let
  user = "lantian";
  group = "users";
in
{
  systemd.services.qbittorrent-pt = {
    description = "qbittorrent BitTorrent client";
    wants = [ "network-online.target" ];
    after = [
      "local-fs.target"
      "network-online.target"
      "nss-lookup.target"
    ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.coreutils}/bin/rm -f -- /var/lib/qbittorrent-pt/qBittorrent/config/lockfile
    '';

    serviceConfig = {
      User = user;
      Group = group;
      StateDirectory = "qbittorrent-pt";

      # For PT sites qBit enhanced is unnecessary
      ExecStart = utils.escapeSystemdExecArgs [
        (lib.getExe pkgs.qbittorrent-nox)
        "--profile=/var/lib/qbittorrent-pt"
        "--webui-port=${LT.portStr.qBitTorrentPT.WebUI}"
        "--torrenting-port=${
          builtins.toString (LT.this.wg-lantian.forwardStart + LT.portForwardOffset.qBitTorrentPT)
        }"
        "--confirm-legal-notice"
      ];
      TimeoutStopSec = 1800;

      # https://github.com/qbittorrent/qBittorrent/pull/6806#discussion_r121478661
      PrivateTmp = false;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];

      Restart = "always";
      RestartSec = "5";
      UMask = "0002";
      LimitNOFILE = 1048576;
      IOSchedulingClass = "idle";
      IOSchedulingPriority = "7";
      MemoryDenyWriteExecute = lib.mkForce false;
    };
  };
  lantian.harden.qbittorrent-pt = {
    enable = true;
    etc = {
      "resolv.conf" = lib.mkDefault true;
      hosts = lib.mkDefault true;
      "ssl/certs/ca-certificates.crt" = lib.mkDefault true;
      "ssl/certs/ca-bundle.crt" =
        lib.mkDefault
          config.environment.etc."ssl/certs/ca-certificates.crt".source;
    };
  };
  systemd.tmpfiles.settings = {
    qbittorrent = {
      "/var/lib/qbittorrent-pt/qBittorrent/"."d" = {
        mode = "755";
        inherit user group;
      };
      "/var/lib/qbittorrent-pt/qBittorrent/config/"."d" = {
        mode = "755";
        inherit user group;
      };
    };
  };

  lantian.localVhosts.pt = {
    locations = {
      "/" = {
        allowCORS = true;
        proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrentPT.WebUI}";
      };
    };
  };
}
