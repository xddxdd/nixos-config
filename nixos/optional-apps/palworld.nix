{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  backupPath = config.lantian.palworld-backup.storage;
in {
  options.lantian.palworld-backup.storage = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/storage/palworld-backup";
    description = "Storage path for Palworld backups";
  };

  config = {
    environment.systemPackages = with pkgs; [rcon];

    systemd.services.palworld = {
      description = "Palworld Server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      requires = ["network.target"];
      environment.HOME = "/var/lib/palworld";

      path = with pkgs; [steamcmd steam-run];

      preStart = ''
        steamcmd \
          +force_install_dir /var/lib/palworld \
          +login anonymous \
          +app_update 2394010 validate \
          +quit
      '';

      script = ''
        mkdir -p .steam/sdk64/
        cp linux64/steamclient.so .steam/sdk64/steamclient.so
        steam-run \
          /var/lib/palworld/PalServer.sh \
            -useperfthreads \
            -NoAsyncLoadingThread \
            -UseMultithreadForDS
      '';

      serviceConfig = {
        User = "palworld";
        Group = "palworld";
        Restart = "on-failure";

        StateDirectory = "palworld";
        WorkingDirectory = "/var/lib/palworld";

        TimeoutStartSec = "1h";

        ProcSubset = "all";
        RestrictNamespaces = false;
        SystemCallFilter = [];
      };
    };

    systemd.services.palworld-backup = {
      description = "Palworld Backup";

      script = ''
        set -x
        SUBDIR=$(date "+%Y_%m_%d_%H_%M_%S")
        cp -r /var/lib/palworld/Pal/Saved "/run/palworld-backup/$SUBDIR"
      '';

      serviceConfig =
        LT.serviceHarden
        // {
          User = "palworld";
          Group = "palworld";

          Type = "oneshot";
          ReadOnlyPaths = ["/var/lib/palworld"];
          ReadWritePaths = ["/run/palworld-backup"];
        };
    };

    systemd.timers.palworld-backup = {
      wantedBy = ["timers.target"];
      partOf = ["palworld-backup.service"];
      timerConfig = {
        OnCalendar = "*:0/10";
        RandomizedDelaySec = "1min";
        Unit = "palworld-backup.service";
      };
    };

    users.users.palworld = {
      group = "palworld";
      isSystemUser = true;
    };
    users.groups.palworld = {};

    fileSystems = {
      "/run/palworld-backup" = lib.mkForce {
        device = backupPath;
        fsType = "fuse.bindfs";
        options = [
          "force-user=palworld"
          "force-group=palworld"
          "perms=700"
          "create-for-user=root"
          "create-for-group=root"
          "chown-ignore"
          "chgrp-ignore"
          "xattr-none"
          "x-gvfs-hide"
        ];
      };
    };
  };
}
