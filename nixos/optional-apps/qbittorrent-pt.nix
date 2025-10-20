{
  pkgs,
  LT,
  config,
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

    serviceConfig = LT.serviceHarden // {
      User = user;
      Group = group;
      StateDirectory = "qbittorrent-pt";

      # For PT sites qBit enhanced is unnecessary
      ExecStart = utils.escapeSystemdExecArgs [
        (lib.getExe pkgs.qbittorrent-nox)
        "--profile=/var/lib/qbittorrent-pt"
        "--webui-port=${LT.portStr.qBitTorrentPT.WebUI}"
        "--torrenting-port=${builtins.toString (LT.this.wg-lantian.forwardStart + 1)}"
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

  lantian.nginxVhosts = {
    "pt.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrentPT.WebUI}";
        };
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "pt.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrentPT.WebUI}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
