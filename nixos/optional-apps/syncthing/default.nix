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
      fsType = "auto";
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

    # Keep off the public internet; OAuth already required
    # (accessibleBy defaults to private)

    systemd.services.syncthing = {
      unitConfig.RequiresMountsFor = map LT.escapeMountPath [
        config.lantian.syncthing.storage
        config.services.syncthing.dataDir
      ];
      serviceConfig = LT.serviceHarden // {
        RestartSec = "5s";
        # Go uses netlink to enumerate interfaces for discovery and NAT traversal.
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
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
        # chroot's tmpfs root is ephemeral; bind the served data through
        BindPaths = [ config.services.syncthing.dataDir ];

        ExecStartPre =
          let
            settingsJSON = pkgs.writeText "syncthing-config.json" (
              builtins.toJSON config.services.syncthing.settings
            );
          in
          "${lib.getExe pkgs.python3} ${./update-config.py} ${settingsJSON} /var/lib/syncthing/config.xml ${lib.getExe config.services.syncthing.package}";
      };
    };
    lantian.harden.syncthing = true;

    # Replaced by custom config script
    systemd.services.syncthing-init.enable = lib.mkForce false;

    systemd.tmpfiles.settings = {
      syncthing = {
        "${config.lantian.syncthing.storage}"."d" = {
          mode = "755";
          inherit (config.services.syncthing) user group;
        };
      };
    };

    lantian.localVhosts.syncthing = {
      locations = {
        "/" = {
          enableOAuth = true;
          proxyPass = "http://127.0.0.1:${LT.portStr.Syncthing}";
        };
      };
    };
  };
}
