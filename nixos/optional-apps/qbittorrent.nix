{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  qbittorrent = pkgs.qbittorrent-enhanced-edition-nox;
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
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      # To prevent "Quit & shutdown daemon" from working; we want systemd to
      # manage it!
      Restart = "on-success";
      User = "lantian";
      Group = "users";
      UMask = "0002";
      LimitNOFILE = 1048576;
    };
  };

  services.nginx.virtualHosts = {
    "qbittorrent.${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "${config.networking.hostName}.xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "qbittorrent.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };
}
