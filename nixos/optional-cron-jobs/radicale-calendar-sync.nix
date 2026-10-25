{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets.radicale-calendar-sync.sopsFile =
    inputs.secrets + "/per-host/radicale-calendar-sync/${config.networking.hostName}.yaml";

  systemd.services.radicale-calendar-sync = {
    path = with pkgs; [ curl ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.bash} -euo pipefail %d/radicale-calendar-sync";
      LoadCredential = [ "radicale-calendar-sync:${config.sops.secrets.radicale-calendar-sync.path}" ];
      RuntimeDirectory = "radicale-calendar-sync";
      WorkingDirectory = "/run/radicale-calendar-sync";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
  };

  lantian.harden.radicale-calendar-sync = {
    enable = true;
    enableConfinement = false;
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
