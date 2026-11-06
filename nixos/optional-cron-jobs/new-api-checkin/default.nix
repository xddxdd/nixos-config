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

  sops.secrets.new-api-checkin-config.sopsFile = inputs.secrets + "/new-api-checkin-config.yaml";

  systemd.services.new-api-checkin = {
    environment = {
      FLARESOLVERR_URL = "http://${LT.constants.localHost.IPv4}:${LT.portStr.FlareSolverr}";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe py} ${./checkin.py} %d/new-api-checkin-config";
      LoadCredential = [ "new-api-checkin-config:${config.sops.secrets.new-api-checkin-config.path}" ];
      Restart = "no";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
    after = [ "network.target" ];
  };
  lantian.harden.new-api-checkin.enable = true;

  systemd.timers.new-api-checkin = {
    wantedBy = [ "timers.target" ];
    partOf = [ "new-api-checkin.service" ];
    timerConfig = {
      OnCalendar = [
        "*-*-* 02:30:00"
        "*-*-* 14:30:00"
      ];
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "new-api-checkin.service";
    };
  };
}
