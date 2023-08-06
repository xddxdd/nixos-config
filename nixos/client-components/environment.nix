{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.udev.packages = with pkgs; [
    crda
    libftdi1
  ];

  services.udisks2.enable = !config.boot.isContainer;
}
