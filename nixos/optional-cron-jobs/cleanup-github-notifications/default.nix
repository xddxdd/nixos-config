{
  pkgs,
  lib,
  LT,
  inputs,
  config,
  ...
}:
let
  py = pkgs.python3.withPackages (p: with p; [ requests ]);
in
{
  age.secrets.cleanup-github-notifications-env.file =
    inputs.secrets + "/cleanup-github-notifications-env.age";

  systemd.services.cleanup-github-notifications = {
    serviceConfig = LT.serviceHarden // {
      EnvironmentFile = config.age.secrets.cleanup-github-notifications-env.path;
      Type = "oneshot";
      ExecStart = "${lib.getExe py} ${./cleanup.py}";
      Restart = "no";
    };
    after = [ "network.target" ];
  };

  systemd.timers.cleanup-github-notifications = {
    wantedBy = [ "timers.target" ];
    partOf = [ "cleanup-github-notifications.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "1h";
      Unit = "cleanup-github-notifications.service";
    };
  };
}
