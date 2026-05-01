{
  config,
  lib,
  LT,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  options.lantian.immich.storage = lib.mkOption {
    type = lib.types.str;
    default = "/nix/persistent/immich";
    description = "Storage path for Immich";
  };

  config = {
    services.immich = {
      enable = true;
      host = "127.0.0.1";
      port = LT.port.Immich;
      mediaLocation = config.lantian.immich.storage;
    };

    lantian.nginxVhosts = {
      "immich.xuyh0120.win" = {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${LT.portStr.Immich}";
            proxyWebsockets = true;
            proxyNoTimeout = true;
          };
        };

        sslCertificate = "zerossl-xuyh0120.win";
        noIndex.enable = true;
      };
      "immich.localhost" = {
        listenHTTP.enable = true;
        listenHTTPS.enable = false;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${LT.portStr.Immich}";
            proxyWebsockets = true;
            proxyNoTimeout = true;
          };
        };

        noIndex.enable = true;
        accessibleBy = "localhost";
      };
    };

    systemd.services.immich-server = {
      after = [ "redis-immich.service" ];
      requires = [ "redis-immich.service" ];
    };

    systemd.services.immich-machine-learning.serviceConfig = {
      PrivateDevices = lib.mkForce false;
    };

    systemd.tmpfiles.settings = {
      immich = {
        "${config.lantian.immich.storage}".d = {
          mode = "755";
          user = "immich";
          group = "immich";
        };
      };
    };
  };
}
