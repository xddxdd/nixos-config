{
  lib,
  LT,
  pkgs,
  ...
}:
let
  py = pkgs.python3.withPackages (p: [ p.requests ]);
in
{
  systemd.services.hydra-check-kernel-jobsets = {
    environment.HYDRA_URL = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra.WebUI}";
    serviceConfig = {
      Type = "oneshot";
      Restart = "no";
      ExecStart = "${lib.getExe py} ${./check-kernel-jobsets.py}";
    };
    unitConfig.OnFailure = "notify-email@%n.service";
    after = [ "network.target" ];
  };
  lantian.harden.hydra-check-kernel-jobsets.enable = true;

  systemd.timers.hydra-check-kernel-jobsets = {
    wantedBy = [ "timers.target" ];
    partOf = [ "hydra-check-kernel-jobsets.service" ];
    timerConfig = {
      OnCalendar = [
        "*-*-* 00:00:00"
        "*-*-* 12:00:00"
      ];
      Persistent = true;
      RandomizedDelaySec = "10min";
      Unit = "hydra-check-kernel-jobsets.service";
    };
  };
}
