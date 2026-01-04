{ lib, pkgs, LT, ... }:
let
  hp-keyboard-backlight = pkgs.callPackage ../../pkgs/hp-keyboard-backlight { };
in
{
  systemd.services.hp-keyboard-backlight = {
    description = "HP Omen Keyboard Backlight";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = lib.getExe hp-keyboard-backlight;

      ProcSubset = "all";
      ProtectKernelTunables = false;
    };
  };
}
