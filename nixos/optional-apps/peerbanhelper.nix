{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
{
  systemd.services.peerbanhelper = {
    description = "Peer Ban Helper";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "qbittorrent.service"
      "qbittorrent-pt.service"
    ];
    requires = [ "network.target" ];

    serviceConfig = LT.serviceHarden // {
      User = "peerbanhelper";
      Group = "peerbanhelper";
      Restart = "on-failure";

      ExecStart = "${lib.getExe pkgs.nur-xddxdd.peerbanhelper}";
      MemoryDenyWriteExecute = false;

      StateDirectory = "peerbanhelper";
      WorkingDirectory = "/var/lib/peerbanhelper";
    };
  };

  lantian.nginxVhosts = {
    "peerbanhelper.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.PeerBanHelper}";
        };
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "peerbanhelper.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.PeerBanHelper}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };

  users.users.peerbanhelper = {
    group = "peerbanhelper";
    isSystemUser = true;
  };
  users.groups.peerbanhelper = { };
}
