{
  pkgs,
  LT,
  config,
  ...
}:
let
  qbittorrent = pkgs.qbittorrent-enhanced.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DGUI=OFF"
      "-DSYSTEMD=ON"
      "-DSYSTEMD_SERVICES_INSTALL_DIR=${placeholder "out"}/lib/systemd/system"
    ];
  });
in
{
  # https://github.com/hercules-ci/nixflk/blob/template/modules/services/torrent/qbittorrent.nix
  systemd.services.qbittorrent = {
    after = [ "network.target" ];
    description = "qBittorrent Daemon";
    wantedBy = [ "multi-user.target" ];
    path = [ qbittorrent ];
    script = ''
      exec ${qbittorrent}/bin/qbittorrent-nox \
        --profile=/var/lib/qbittorrent \
        --webui-port=${LT.portStr.qBitTorrent.WebUI}
    '';
    serviceConfig = LT.serviceHarden // {
      StateDirectory = "qbittorrent";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      # To prevent "Quit & shutdown daemon" from working; we want systemd to
      # manage it!
      Restart = "on-success";
      User = "lantian";
      Group = "users";
      UMask = "0002";
      LimitNOFILE = 1048576;
    };
  };

  lantian.nginxVhosts = {
    "qbittorrent.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          allowCORS = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
        };
      };

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
