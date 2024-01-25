{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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
      cp -r /var/lib/palworld/Pal/Saved "/var/lib/palworld-backup/$SUBDIR"
    '';

    serviceConfig =
      LT.serviceHarden
      // {
        User = "palworld";
        Group = "palworld";

        Type = "oneshot";
        ReadWritePaths = ["/var/lib/palworld"];
        StateDirectory = "palworld-backup";
        WorkingDirectory = "/var/lib/palworld-backup";
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
}
