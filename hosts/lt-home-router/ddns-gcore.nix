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
  sops.secrets.ddns-gcore-env = {
    sopsFile = inputs.secrets + "/ddns.yaml";
  };

  systemd.services.ddns-gcore = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.ddns-gcore-env.path;
      ExecStart = "${lib.getExe py} ${./ddns_gcore.py}";
      Restart = "no";
    };
    after = [ "network.target" ];
  };

  systemd.timers.ddns-gcore = {
    wantedBy = [ "timers.target" ];
    partOf = [ "ddns-gcore.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "ddns-gcore.service";
    };
  };
}
