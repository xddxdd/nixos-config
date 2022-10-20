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
  home.packages = with pkgs; [
    (LT.wrapNetns "ns-wg-lantian" deluge)
    (LT.wrapNetns "ns-wg-lantian" qbittorrent-enhanced-edition)
    (lutris.override { extraPkgs = p: with p; [ xdelta ]; })
    android-tools
    aria
    audacious
    baidupcs-go
    bilibili
    calibre
    chromium-oqs-bin
    cloudpan189-go
    colmena
    dbeaver
    deepspeech-gpu
    deepspeech-wrappers
    discord
    element-desktop
    ffmpeg-full
    filezilla
    firefox
    gcdemu
    gimp-with-plugins
    gnome.gedit
    google-chrome
    gopherus
    libfaketime
    librewolf
    libsForQt5.ark
    linphone
    lm_sensors
    mediainfo
    megatools
    mpv
    newsflash
    nix-top
    nix-tree
    nvfetcher
    openvpn
    osdlyrics
    payload-dumper-go
    # polymc
    qq
    quasselClient
    tdesktop
    thunderbird
    tigervnc
    transmission-qt
    transmission-remote-gtk
    ulauncher
    vagrant
    virt-manager
    vopono
    vscode
    wechat-uos
    winetricks
    wineWowPackages.stable
    wordle
    wpsoffice
    yubikey-manager-qt
    yuzu-mainline
    zoom-us
  ];

  xdg.configFile = LT.gui.autostart [
    { name = "discord"; command = "${pkgs.discord}/bin/discord --start-minimized"; }
    { name = "element"; command = "${pkgs.element-desktop}/bin/element-desktop --hidden"; }
    { name = "gcdemu"; command = "${pkgs.gcdemu}/bin/gcdemu"; }
    { name = "telegram"; command = "${pkgs.tdesktop}/bin/telegram-desktop -autostart"; }
    { name = "thunderbird"; command = "${pkgs.thunderbird}/bin/thunderbird"; }
    { name = "ulauncher"; command = "${pkgs.ulauncher}/bin/ulauncher --hide-window"; }
  ];

  xdg.dataFile = builtins.listToAttrs (lib.flatten (builtins.map
    (size: [
      # https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/
      {
        name = "icons/hicolor/${builtins.toString size}x${builtins.toString size}/apps/firefox.png";
        value.source =
          if size < 48
          then LT.gui.resizeIcon size ../files/mikozilla-fireyae.png
          else LT.gui.resizeIcon size ../files/mikozilla-fireyae-petals.png;
      }
    ])
    [ 8 10 14 16 22 24 32 36 40 48 64 72 96 128 192 256 480 512 ]));
}
