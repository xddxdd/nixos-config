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
    services.syncthing = {
      enable = true;
      user = "rslsync";
      group = "rslsync";
      configDir = "/var/lib/syncthing";
      dataDir = config.lantian.syncthing.storage;

      extraOptions = {
        options = {
          startBrowser = false;
          natEnabled = !(builtins.elem LT.tags.server LT.this.tags);
          urAccepted = -1;
          progressUpdateIntervalS = -1;
        };
      };
    };

    # Keep using Resilio Sync user for compatibility
    users.users.rslsync = {
      description = "Resilio Sync Service user";
      uid = config.ids.uids.rslsync;
      group = "rslsync";
    };
    users.groups.rslsync = {};

    environment.systemPackages = [config.services.syncthing.package];

    systemd.services.syncthing = {
      environment = {
        GOGC = "1";
        LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
      };
      serviceConfig = {
        CPUQuota = "10%";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/syncthing 755 root root"
      "d /nix/persistent/sync-servers 775 root root"
    ];
  };
}
