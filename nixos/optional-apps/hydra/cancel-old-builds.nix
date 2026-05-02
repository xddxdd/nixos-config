{
  lib,
  LT,
  config,
  pkgs,
  ...
}:
let
  py = pkgs.python3.withPackages (p: [ p.requests ]);
in
{
  systemd.services.hydra-cancel-old-builds = {
    environment = {
      BASE_URL = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra}";
      USERNAME = "lantian";
    };
    script = ''
      export PASSWORD=$(cat ${config.sops.secrets.default-pw.path})
      exec ${lib.getExe py} ${./cancel-old-builds.py}
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      Restart = "no";
    };
    after = [ "network.target" ];
  };

  systemd.timers.hydra-cancel-old-builds = {
    wantedBy = [ "timers.target" ];
    partOf = [ "hydra-cancel-old-builds.service" ];
    timerConfig = {
      OnCalendar = "*:0/6:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
      Unit = "hydra-cancel-old-builds.service";
    };
  };
}
