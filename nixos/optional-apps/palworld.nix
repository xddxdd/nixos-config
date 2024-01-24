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

  users.users.palworld = {
    group = "palworld";
    isSystemUser = true;
  };
  users.groups.palworld = {};
}
