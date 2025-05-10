{
  config,
  lib,
  LT,
  ...
}:
{
  options.lantian.immich.storage = lib.mkOption {
    type = lib.types.str;
    default = "/nix/persistent/immich";
    description = "Storage path for Immich";
  };

  config = {
    fileSystems."/run/immich" = {
      device = config.lantian.immich.storage;
      fsType = "fuse.bindfs";
      options = [
        "force-user=${config.services.immich.user}"
        "force-group=${config.services.immich.group}"
        "perms=700"
        "create-for-user=lantian"
        "create-for-group=users"
        "create-with-perms=755"
        "chmod-ignore"
        "chown-ignore"
        "chgrp-ignore"
        "xattr-none"
        "x-gvfs-hide"
        "multithreaded"
      ];
    };

    services.immich = {
      enable = true;
      host = "127.0.0.1";
      port = LT.port.Immich;
      mediaLocation = "/run/immich";
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

        sslCertificate = "xuyh0120.win_ecc";
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
      after = [
        "run-immich.mount"
        "redis-immich.service"
      ];
      requires = [
        "run-immich.mount"
        "redis-immich.service"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${config.lantian.immich.storage} 755 lantian users"
    ];
  };
}
