{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.syncthing.storage = lib.mkOption {
    type = lib.types.str;
    default = "/nix/persistent/media";
    description = "Storage path for Syncthing";
  };

  config = {
    fileSystems."/run/syncthing-files" = {
      device = config.lantian.syncthing.storage;
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions' [
        "force-user=syncthing"
        "force-group=syncthing"
        "perms=700"
        "create-for-user=root"
        "create-for-group=root"
        "create-with-perms=755"
        "chmod-ignore"
      ];
    };

    services.syncthing = {
      enable = true;
      user = "syncthing";
      group = "syncthing";
      configDir = "/var/lib/syncthing";
      dataDir = "/run/syncthing-files";
      guiAddress = "127.0.0.1:${LT.portStr.Syncthing}";

      overrideFolders = false;
      overrideDevices = false;

      settings = {
        options = {
          startBrowser = false;
          natEnabled = !(LT.this.hasTag LT.tags.server);
          urAccepted = -1;
          progressUpdateIntervalS = -1;
          relaysEnabled = true;
        };
        gui.insecureSkipHostcheck = true;
        defaults.device.autoAcceptFolders = true;
        defaults.folder.rescanIntervalS = 300;
      };
    };

    # Keep using Resilio Sync user for compatibility
    users.users.syncthing = {
      uid = config.ids.uids.syncthing;
      group = "syncthing";
    };
    users.groups.syncthing.members = [ "nginx" ];

    environment.systemPackages = [ config.services.syncthing.package ];

    systemd.services.syncthing = {
      serviceConfig = {
        RuntimeDirectory = "syncthing";
        StateDirectory = "syncthing";
      };
    };

    systemd.tmpfiles.rules = [ "d ${config.lantian.syncthing.storage} 755 root root" ];

    lantian.nginxVhosts = {
      "syncthing.${config.networking.hostName}.xuyh0120.win" = {
        locations = {
          "/" = {
            enableOAuth = true;
            proxyPass = "http://127.0.0.1:${LT.portStr.Syncthing}";
          };
        };

        sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
        noIndex.enable = true;
      };
      "syncthing.localhost" = {
        listenHTTP.enable = true;
        listenHTTPS.enable = false;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${LT.portStr.Syncthing}";
          };
        };

        noIndex.enable = true;
        accessibleBy = "localhost";
      };
    };
  };
}
