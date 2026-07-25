{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.lantian.hostType = lib.mkOption {
    type = lib.types.enum [
      "physical"
      "vm"
      "vm-passthrough"
    ];
    default = "physical";
  };

  config = lib.mkIf (config.lantian.hostType != "vm") {
    environment.systemPackages = with pkgs; [
      ethtool
      iw
      lm_sensors
      pciutils
      smartmontools
      usbutils
    ];

    programs.htop.package = pkgs.htop.override { sensorsSupport = false; };
  };
}
