{ pkgs, lib, ... }:
{
  services.udev.packages = with pkgs; [
    libftdi1
    yubikey-manager
    yubikey-personalization
  ];

  services.udisks2.enable = true;
  services.pcscd.enable = lib.mkForce false; # Interferes with GPG accessing Yubikey
}
