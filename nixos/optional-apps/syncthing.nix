{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  options.lantian.syncthing.storage = lib.mkOption {
    type = lib.types.str;
    default = "/nix/persistent/media";
    description = "Storage path for Syncthing";
  };

  config = {
    fileSystems."/run/syncthing-files" = {
      device = config.lantian.syncthing.storage;
      fsType = "fuse.bindfs";
      options = [
        "force-user=syncthing"
        "force-group=syncthing"
        "create-for-user=root"
        "create-for-group=root"
        "chown-ignore"
        "chgrp-ignore"
        "xattr-none"
        "x-gvfs-hide"
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
          natEnabled = !(builtins.elem LT.tags.server LT.this.tags);
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
    users.groups.syncthing.members = ["nginx"];

    environment.systemPackages = [config.services.syncthing.package];

    systemd.services.syncthing = {
      serviceConfig = {
        RuntimeDirectory = "syncthing";
        StateDirectory = "syncthing";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${config.lantian.syncthing.storage} 755 root root"
    ];

    lantian.nginxVhosts = {
      "syncthing.${config.networking.hostName}.xuyh0120.win" = {
        locations = {
          "/" = {
            enableOAuth = true;
            proxyPass = "http://127.0.0.1:${LT.portStr.Syncthing}";
          };
        };

        sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
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
