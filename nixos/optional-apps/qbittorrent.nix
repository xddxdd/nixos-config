{
  pkgs,
  lib,
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

  systemd.services.vuetorrent-backend = {
    description = "VueTorrent backend";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      PORT = LT.portStr.qBitTorrent.VueTorrent;
      QBIT_BASE = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
      CONFIG_PATH = "/var/lib/vuetorrent-backend";
      VUETORRENT_PATH = "/var/cache/vuetorrent-backend";
    };
    serviceConfig = LT.serviceHarden // {
      ExecStart = "${pkgs.nur-xddxdd.vuetorrent-backend}/bin/vuetorrent-backend";

      User = "vuetorrent-backend";
      Group = "vuetorrent-backend";
      CacheDirectory = "vuetorrent-backend";
      StateDirectory = "vuetorrent-backend";

      Restart = "always";
      MemoryDenyWriteExecute = lib.mkForce false;
    };
  };

  users.users.vuetorrent-backend = {
    group = "vuetorrent-backend";
    isSystemUser = true;
  };
  users.groups.vuetorrent-backend = { };

  lantian.nginxVhosts = {
    "qbittorrent.${config.networking.hostName}.xuyh0120.win" = {
      root = "${pkgs.vuetorrent}/share/vuetorrent/public";
      locations = {
        "/api" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
        };
        "/backend" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.VueTorrent}";
        };
      };

      accessibleBy = "private";
      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "qbittorrent.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      root = "${pkgs.vuetorrent}/share/vuetorrent/public";
      locations = {
        "/api" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
        };
        "/backend" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.VueTorrent}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
