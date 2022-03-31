{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

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
    firefox
    gnome.gedit
    google-chrome
    libfaketime
    libsForQt5.ark
    mpv
    osdlyrics
    tigervnc
    transmission-qt
    transmission-remote-gtk
    virt-manager
    vscode
    wechat-uos
    wine-wechat
    wordle
    wpsoffice
    zoom-us
  ];

  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
