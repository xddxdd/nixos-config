{
  pkgs,
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
      "transmission.service"
    ];
    requires = [ "network.target" ];

    serviceConfig = LT.serviceHarden // {
      User = "peerbanhelper";
      Group = "peerbanhelper";
      Restart = "on-failure";

      ExecStart = "${pkgs.nur-xddxdd.peerbanhelper}/bin/peerbanhelper";
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

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
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
