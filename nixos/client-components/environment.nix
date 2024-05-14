{ pkgs, config, ... }:
{
  services.udev.packages = with pkgs; [ libftdi1 ];

  services.udisks2.enable = !config.boot.isContainer;
}
