{
  inputs,
  config,
  pkgs,
  LT,
  ...
}:
{
  age.secrets.radicale-calendar-sync.file = inputs.secrets + "/radicale-calendar-sync.age";

  systemd.services.radicale-calendar-sync = {
    path = with pkgs; [ curl ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.age.secrets.radicale-calendar-sync.path}";
    };
  };

  systemd.timers.radicale-calendar-sync = {
    wantedBy = [ "timers.target" ];
    partOf = [ "oci-arm-host-capacity.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "300";
      Unit = "oci-arm-host-capacity.service";
    };
  };
}
