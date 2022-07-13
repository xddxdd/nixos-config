{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-firmware
  ];

  services.fwupd.enable = true;
}
