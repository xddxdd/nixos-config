{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  users.users.lantian.extraGroups = [ "wireshark" ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
