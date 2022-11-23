{ pkgs, lib, config, utils, inputs, ... }@args:

{
  environment.systemPackages = with pkgs; [
    gnome-firmware
  ];

  services.fwupd.enable = true;
}
