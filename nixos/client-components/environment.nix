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
    libftdi1
  ];

  services.udisks2.enable = !config.boot.isContainer;
}
