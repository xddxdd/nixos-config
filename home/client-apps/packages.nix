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
    cloudpan189-go
    colmena
    deepspeech-gpu
    deepspeech-wrappers
    discord
    element-desktop
    ffmpeg-full
    filezilla
    firefox
    flake.agenix.packages."${system}".agenix
    gcdemu
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
    mediainfo
    megatools
    minecraft
    mpv
    nix-top
    nix-tree
    nodePackages.node2nix
    nvfetcher
    osdlyrics
    playonlinux
    qq
    quasselClient
    rnix-lsp
    tdesktop
    thunderbird
    tigervnc
    transmission-qt
    transmission-remote-gtk
    ulauncher
    virt-manager
    vscode
    wechat-uos
    winetricks
    wineWowPackages.stable
    wordle
    wpsoffice
    yuzu
    zoom-us
  ];

  xdg.configFile = LT.autostart [
    ({ name = "discord"; command = "${pkgs.discord}/bin/discord --start-minimized"; })
    ({ name = "element"; command = "${pkgs.element-desktop}/bin/element-desktop --hidden"; })
    ({ name = "gcdemu"; command = "${pkgs.gcdemu}/bin/gcdemu"; })
    ({ name = "telegram"; command = "${pkgs.tdesktop}/bin/telegram-desktop -autostart"; })
    ({ name = "thunderbird"; command = "${pkgs.thunderbird}/bin/thunderbird"; })
    ({ name = "ulauncher"; command = "${pkgs.ulauncher}/bin/ulauncher --hide-window"; })
  ];
}
