{
  pkgs,
  ...
}:
{
  systemd.services.smfc = {
    description = "Super Micro Fan Control";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      python3
      ipmitool
    ];

    script = ''
      # Workaround issue of setting fan to max on startup
      timeout 10 python3 ${./smfc.py} -c ${./smfc.conf} -l 3 || true
      exec python3 ${./smfc.py} -c ${./smfc.conf} -l 3
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      ProcSubset = "all";
      ProtectKernelTunables = false;
      PrivateDevices = false;
    };
  };
  lantian.harden.smfc.enable = true;
}
