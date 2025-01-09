{
  LT,
  pkgs,
  inputs,
  config,
  ...
}:
let
  py = pkgs.python3.withPackages (ps: with ps; [ requests ]);
in
{
  age.secrets.inseego-mifi-password.file = inputs.secrets + "/inseego-mifi-password.age";

  systemd.services.inseego-mifi-restart = {
    description = "Inseego MiFi Restart";
    after = [ "network.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${py}/bin/python3 ${./script.py}";
      EnvironmentFile = config.age.secrets.inseego-mifi-password.path;
    };
  };

  systemd.timers.inseego-mifi-restart = {
    wantedBy = [ "timers.target" ];
    partOf = [ "inseego-mifi-restart.service" ];
    timerConfig = {
      OnCalendar = [ "*-*-* 06:00:00" ];
      Persistent = true;
      Unit = "inseego-mifi-restart.service";
    };
  };
}
