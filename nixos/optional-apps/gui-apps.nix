{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  # Quickstart for wordle, set time offset to advance into next day
  wordle = pkgs.writeShellScriptBin "wordle" ''
    ${pkgs.libfaketime}/bin/faketime \
      -f "+12h" \
      ${pkgs.google-chrome}/bin/google-chrome-stable \
      https://www.nytimes.com/games/wordle/index.html
  '';
in
{
  environment.systemPackages = with pkgs; [
    aria
    android-tools
    audacious
    calibre
    colmena
    (LT.wrapNetns "ns-wg-lantian" deluge)
    dingtalk
    distrobox
    filezilla
    firefox
    gnome.gedit
    google-chrome
    gopherus
    libfaketime
    libsForQt5.ark
    lm_sensors
    minecraft
    mpv
    osdlyrics
    (LT.wrapNetns "ns-wg-lantian" qbittorrent-enhanced-edition)
    quasselClient
    tigervnc
    transmission-qt
    transmission-remote-gtk
    virt-manager
    vscode
    wechat-uos
    wine
    winetricks
    wordle
    wpsoffice
    zoom-us
  ];

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
