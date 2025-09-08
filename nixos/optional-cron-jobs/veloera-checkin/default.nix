{
  pkgs,
  LT,
  inputs,
  config,
  ...
}:
let
  py = pkgs.python3.withPackages (p: with p; [ curl-cffi ]);
in
{
  age.secrets.veloera-checkin-config.file = inputs.secrets + "/veloera-checkin-config.age";

  systemd.services.veloera-checkin = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${py}/bin/python3 ${./checkin.py} ${config.age.secrets.veloera-checkin-config.path}";
      Restart = "no";
    };
    unitConfig = {
      OnFailure = "notify-email-fail@%n.service";
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
