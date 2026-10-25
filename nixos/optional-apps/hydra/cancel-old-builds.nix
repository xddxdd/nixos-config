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
      BASE_URL = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra.WebUI}";
      USERNAME = "scripts";
    };
    script = ''
      export PASSWORD=$(cat $CREDENTIALS_DIRECTORY/password)
      exec ${lib.getExe py} ${./cancel-old-builds.py}
    '';
    serviceConfig = {
      Type = "oneshot";
      Restart = "no";
      LoadCredential = [ "password:${config.sops.secrets.hydra-script-password.path}" ];
    };
    after = [ "network.target" ];
  };
  lantian.harden.hydra-cancel-old-builds.enable = true;

  systemd.timers.hydra-cancel-old-builds = {
    wantedBy = [ "timers.target" ];
    partOf = [ "hydra-cancel-old-builds.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "10min";
      Unit = "hydra-cancel-old-builds.service";
    };
  };
}
