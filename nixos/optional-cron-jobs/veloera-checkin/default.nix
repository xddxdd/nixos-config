{
  pkgs,
  lib,
  LT,
  inputs,
  config,
  ...
}:
let
  py = pkgs.python3.withPackages (p: with p; [ curl-cffi ]);
in
{
  imports = [ ../../optional-apps/byparr.nix ];

  age.secrets.veloera-checkin-config.file = inputs.secrets + "/veloera-checkin-config.age";

  systemd.services.veloera-checkin = {
    environment = {
      FLARESOLVERR_URL = "http://127.0.0.1:${LT.portStr.FlareSolverr}";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${lib.getExe py} ${./checkin.py} ${config.age.secrets.veloera-checkin-config.path}";
      Restart = "no";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
    after = [ "network.target" ];
  };

  systemd.timers.veloera-checkin = {
    wantedBy = [ "timers.target" ];
    partOf = [ "veloera-checkin.service" ];
    timerConfig = {
      OnCalendar = [
        "*-*-* 02:30:00"
        "*-*-* 14:30:00"
      ];
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "veloera-checkin.service";
    };
  };
}
