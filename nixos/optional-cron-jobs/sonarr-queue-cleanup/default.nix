{
  pkgs,
  lib,
  LT,
  ...
}:
let
  py = pkgs.python3.withPackages (p: with p; [ requests ]);
in
{
  systemd.services.sonarr-queue-cleanup = {
    environment = {
      SONARR_URL = "http://127.0.0.1:${LT.portStr.Sonarr}";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${lib.getExe py} ${./cleanup.py}";
      Restart = "no";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
    after = [
      "network.target"
      "sonarr.service"
    ];
    requires = [ "sonarr.service" ];
  };

  systemd.timers.sonarr-queue-cleanup = {
    wantedBy = [ "timers.target" ];
    partOf = [ "sonarr-queue-cleanup.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "1h";
      Unit = "sonarr-queue-cleanup.service";
    };
  };
}
