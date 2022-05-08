{ config, pkgs, lib, ... }:

{
  systemd.services.nbfc-linux = let
    cfg = pkgs.writeText "nbfc.json" (builtins.toJSON {
      SelectedConfigId = "HP Omen 17t-ck000";
      EmbeddedControllerType = "ec_sys_linux";
    });
  in {
    description = "NBFC-Linux";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.kmod ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nbfc-lantian}/bin/nbfc_service -c ${cfg}";
      TimeoutStopSec = "5";
    };
  };
}
