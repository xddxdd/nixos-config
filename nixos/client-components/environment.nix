{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (!config.boot.isContainer) {
  services.udev.packages = with pkgs; [
    libftdi1
    yubikey-personalization
  ];

  services.udisks2.enable = true;
  services.pcscd.enable = true;
}
