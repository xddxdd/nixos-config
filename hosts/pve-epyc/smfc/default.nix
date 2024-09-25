{ pkgs, ... }:
{
  systemd.services.smfc = {
    description = "Super Micro Fan Control";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.smfc}/bin/smfc -c ${./smfc.conf} -l 3";

      ProcSubset = "all";
      ProtectKernelTunables = false;
    };
  };
}
