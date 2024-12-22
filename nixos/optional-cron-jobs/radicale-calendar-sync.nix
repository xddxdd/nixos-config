{
  inputs,
  config,
  pkgs,
  LT,
  ...
}:
{
  age.secrets.radicale-calendar-sync.file =
    inputs.secrets + "/radicale-calendar-sync/${config.networking.hostName}.age";

  systemd.services.radicale-calendar-sync = {
    path = with pkgs; [ curl ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -euo pipefail ${config.age.secrets.radicale-calendar-sync.path}";
      RuntimeDirectory = "radicale-calendar-sync";
      WorkingDirectory = "/run/radicale-calendar-sync";
    };
  };

  systemd.timers.radicale-calendar-sync = {
    wantedBy = [ "timers.target" ];
    partOf = [ "radicale-calendar-sync.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "300";
      Unit = "radicale-calendar-sync.service";
    };
  };
}
