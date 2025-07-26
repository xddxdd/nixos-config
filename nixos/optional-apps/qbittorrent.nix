{
  pkgs,
  LT,
  config,
  ...
}:
{
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-enhanced-nox;
    user = "lantian";
    group = "users";
    profileDir = "/var/lib/qbittorrent";
    webuiPort = LT.port.qBitTorrent.WebUI;
    torrentingPort = LT.this.wg-lantian.forwardStart;
    extraArgs = [
      "--confirm-legal-notice"
    ];
  };

  systemd.services.qbittorrent.serviceConfig = {
    Restart = "always";
    RestartSec = "5";
    UMask = "0002";
    LimitNOFILE = 1048576;
  };

  lantian.nginxVhosts = {
    "qbittorrent.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
        };
      };

      accessibleBy = "private";
      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "qbittorrent.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
