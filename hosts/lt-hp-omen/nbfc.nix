{ pkgs,
  lib, config, ... }:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi-ec ];
  boot.kernelModules = [ "acpi_ec" ];

  systemd.services.nbfc-linux =
    let
      cfg = pkgs.writeText "nbfc.json" (
        builtins.toJSON {
          SelectedConfigId = "HP Omen 17t-ck000";
          EmbeddedControllerType = "ec_sys_linux";
        }
      );
    in
    {
      description = "NBFC-Linux";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.kmod ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${lib.getExe' pkgs.nur-xddxdd.lantianCustomized.nbfc-linux "nbfc_service"} -c ${cfg}";
        TimeoutStopSec = "5";
      };
    };
}
