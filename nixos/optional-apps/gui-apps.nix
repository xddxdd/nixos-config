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
    baidupcs-go
    bilibili
    calibre
    cloudpan189-go
    colmena
    deepspeech-gpu
    deepspeech-wrappers
    (LT.wrapNetns "ns-wg-lantian" deluge)
    dingtalk
    ffmpeg
    filezilla
    firefox
    gimp-with-plugins
    gnome.gedit
    google-chrome
    gopherus
    kubectl
    kubernetes-helm
    libfaketime
    librewolf
    libsForQt5.ark
    linphone
    lm_sensors
    (lutris.override { extraPkgs = p: with p; [ xdelta ]; })
    mediainfo
    megatools
    minecraft
    mpv
    nix-top
    osdlyrics
    playonlinux
    (LT.wrapNetns "ns-wg-lantian" qbittorrent-enhanced-edition)
    qq
    quasselClient
    tigervnc
    transmission-qt
    transmission-remote-gtk
    virt-manager
    vscode
    wechat-uos
    wineWowPackages.stable
    winetricks
    wordle
    wpsoffice
    yuzu
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
