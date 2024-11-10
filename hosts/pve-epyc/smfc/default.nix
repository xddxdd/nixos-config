{ pkgs, ... }:
{
  systemd.services.smfc = {
    description = "Super Micro Fan Control";
    wantedBy = [ "multi-user.target" ];

    script = ''
      # Workaround issue of setting fan to max on startup
      timeout 10 ${pkgs.nur-xddxdd.smfc}/bin/smfc -c ${./smfc.conf} -l 3 || true
      exec ${pkgs.nur-xddxdd.smfc}/bin/smfc -c ${./smfc.conf} -l 3
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      ProcSubset = "all";
      ProtectKernelTunables = false;
    };
  };
}
