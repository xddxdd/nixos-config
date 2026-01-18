{
  lib,
  LT,
  config,
  pkgs,
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
      options = [ "bind" ];
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
        AmbientCapabilities = [
          "CAP_DAC_OVERRIDE"
          "CAP_FOWNER"
        ];
        CapabilityBoundingSet = [
          "CAP_DAC_OVERRIDE"
          "CAP_FOWNER"
        ];
        ReadWritePaths = [ "/run/syncthing-files" ];
        RuntimeDirectory = "syncthing";
        StateDirectory = "syncthing";

        ExecStartPre = let
          settingsJSON = pkgs.writeText "syncthing-config.json" (builtins.toJSON config.services.syncthing.settings);
        in "${lib.getExe pkgs.python3} ${./update-config.py} ${settingsJSON} /var/lib/syncthing/config.xml";
      };
    };

    # Replaced by custom config script
    systemd.services.syncthing-init.enable = lib.mkForce false;

    systemd.tmpfiles.settings = {
      syncthing = {
        "${config.lantian.syncthing.storage}"."d" = {
          mode = "755";
          user = "root";
          group = "root";
        };
      };
    };

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
