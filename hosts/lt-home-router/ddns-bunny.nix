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
  sops.secrets.ddns-bunny-env = {
    sopsFile = inputs.secrets + "/ddns.yaml";
  };

  systemd.services.ddns-bunny = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.ddns-bunny-env.path;
      ExecStart = "${lib.getExe py} ${./ddns_bunny.py}";
      Restart = "no";
    };
    after = [ "network.target" ];
  };

  systemd.timers.ddns-bunny = {
    wantedBy = [ "timers.target" ];
    partOf = [ "ddns-bunny.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "ddns-bunny.service";
    };
  };
}
