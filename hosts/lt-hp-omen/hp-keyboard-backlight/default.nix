{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  systemd.services.hp-keyboard-backlight = {
    description = "HP Omen Keyboard Backlight";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.python3}/bin/python3 ${./script.py}";

      ProcSubset = "all";
      ProtectKernelTunables = false;
    };
  };
}
