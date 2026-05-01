{
  lib,
  LT,
  pkgs,
  ...
}:
let
  py = pkgs.python3.withPackages (ps: [ ps.requests ]);
in
{
  systemd.services.hydra-watchdog = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.systemd ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      ExecStart = "${lib.getExe' py "python3"} ${./watchdog.py}";
      Restart = "on-failure";
      RestartSec = "60";
    };
  };
}
