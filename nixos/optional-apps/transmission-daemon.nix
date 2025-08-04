{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  services.transmission = {
    enable = true;
    package = pkgs.nur-xddxdd.lantianCustomized.transmission-with-webui;
    user = "lantian";
    group = "users";
    downloadDirPermissions = "775";
    settings = {
      cache-size-mb = 0;
      download-dir = lib.mkDefault "/nix/persistent/media/Transmission";
      download-queue-enabled = false;
      encryption = 2;
      idle-seeding-limit-enabled = false;
      incomplete-dir-enabled = false;
      peer-limit-global = 10000;
      peer-limit-per-torrent = 10000;
      peer-port = LT.this.wg-lantian.forwardStart + 9;
      peer-socket-tos = "lowcost";
      queue-stalled-enabled = false;
      rename-partial-files = true;
      rpc-bind-address = LT.this.ltnet.IPv4;
      rpc-host-whitelist-enabled = false;
      rpc-port = LT.port.Transmission;
      rpc-whitelist-enabled = false;
      seed-queue-enabled = false;
    };
  };

  systemd.services.transmission.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  lantian.nginxVhosts = {
    "transmission.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          enableOAuth = true;
          proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Transmission}";
        };
        "/transmission/web".alias = "${pkgs.transmission}/share/transmission/web";
      };

      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "transmission.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Transmission}";
        };
        "/transmission/web".alias = "${pkgs.transmission}/share/transmission/web";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
