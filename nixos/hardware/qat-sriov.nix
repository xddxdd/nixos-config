{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lantian.qat-sriov;
in
{
  options.lantian.qat-sriov.devicePath = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Sysfs device path of the Intel QAT PF whose VFs should be enabled at boot.";
  };

  config = lib.mkIf (cfg.devicePath != null) {
    systemd.services.qat-sriov = {
      description = "Enable Intel QAT SRIOV";
      wantedBy = [ "multi-user.target" ];
      after = [
        "systemd-modules-load.service"
        "systemd-udev-trigger.service"
      ];
      requires = [ "systemd-modules-load.service" ];
      before = [
        "pve-guests.service"
        "pvedaemon.service"
      ];
      path = [ pkgs.kmod ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "3";
      };
      # Reconfiguring VFs while guests use them is unsafe.
      restartIfChanged = false;
      script = ''
        DEVICE_PATH=${cfg.devicePath}
        NUMVFS=$(cat "$DEVICE_PATH/sriov_totalvfs")
        echo "$NUMVFS" > "$DEVICE_PATH/sriov_numvfs"
      '';
    };
  };
}
