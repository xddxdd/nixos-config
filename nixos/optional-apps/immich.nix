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
      # Very long build time
      # package = pkgsWithCuda.immich;
      host = "127.0.0.1";
      port = LT.port.Immich;
      mediaLocation = config.lantian.immich.storage;
      accelerationDevices = null; # Enable all GPUs
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

        accessibleBy = "private";
        sslCertificate = "lets-encrypt-xuyh0120.win";
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
      unitConfig.RequiresMountsFor = [ (LT.escapeMountPath config.services.immich.mediaLocation) ];
      serviceConfig = LT.serviceHarden // {
        MemoryDenyWriteExecute = lib.mkForce false;
        BindPaths = [
          config.services.immich.mediaLocation
          "/run/postgresql"
          "/run/redis-immich"
        ];
      };
      after = [ "redis-immich.service" ];
      requires = [ "redis-immich.service" ];
    };
    lantian.harden.immich-server = true;

    systemd.services.immich-machine-learning = {
      serviceConfig = LT.serviceHarden;
    };
    lantian.harden.immich-machine-learning = true;

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
