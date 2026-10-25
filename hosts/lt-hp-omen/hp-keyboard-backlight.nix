{
  lib,
  pkgs,
  ...
}:
let
  hp-keyboard-backlight = pkgs.callPackage ../../pkgs/hp-keyboard-backlight { };
in
{
  systemd.services.hp-keyboard-backlight = {
    description = "HP Omen Keyboard Backlight";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = lib.getExe hp-keyboard-backlight;

      ProcSubset = "all";
      ProtectKernelTunables = false;
    };
  };
  lantian.harden.hp-keyboard-backlight.enable = true;
}
