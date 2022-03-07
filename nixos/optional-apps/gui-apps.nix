{ config, pkgs, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  environment.systemPackages = with pkgs; [
    aria
    android-tools
    audacious
    calibre
    colmena
    distrobox
    firefox
    gnome.gedit
    google-chrome
    libsForQt5.ark
    mpv
    virt-manager
    vscode
    wechat-uos
    wine-wechat
    wpsoffice
    zoom-us
  ];

  programs.steam.enable = true;

  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
