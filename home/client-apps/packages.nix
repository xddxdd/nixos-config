{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  step-cli-wrapped = pkgs.writeShellScriptBin "step" ''
    export STEPPATH="$HOME/.local/share/step"
    exec ${pkgs.step-cli}/bin/step "$@"
  '';
in {
  home.packages = with pkgs; [
    (LT.wrapNetns "wg-lantian" amule-dlp)
    (LT.wrapNetns "wg-lantian" deluge)
    (LT.wrapNetns "wg-lantian" qbittorrent-enhanced-edition)
    (lutris.override {extraPkgs = p: with p; [xdelta];})
    appimage-run
    aria
    attic-client
    audacious
    baidupcs-go
    bilibili
    calibre
    cloudpan189-go
    colmena
    dbeaver
    discord
    discord-canary
    distrobox
    element-desktop
    exiftool
    ffmpeg-full
    filezilla
    gcdemu
    gimp
    gnome.gedit
    # Disabled for build failure
    # google-earth-pro
    gopherus
    imagemagick
    jellyfin-media-player
    kdenlive
    libfaketime
    librewolf
    libsForQt5.ark
    libsForQt5.kpat
    linphone
    macchanger
    matrix-synapse-tools.synadm
    mediainfo
    megatools
    mpv
    newsflash
    nvfetcher
    openvpn
    parsec-bin
    payload-dumper-go
    powertop
    prismlauncher
    qq
    quasselClient
    remmina
    space-cadet-pinball-full-tilt
    steam-run
    step-cli-wrapped
    svp
    tdesktop
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
    wpsoffice
    xca
    yt-dlp
    yubikey-manager-qt
    yuzu-mainline
    zoom-us
  ];

  xdg.configFile = LT.gui.autostart [
    {
      name = "discord";
      command = "${pkgs.discord}/bin/discord --start-minimized";
    }
    {
      name = "discord-canary";
      command = "${pkgs.discord-canary}/bin/discordcanary --start-minimized";
    }
    {
      name = "element";
      command = "${pkgs.element-desktop}/bin/element-desktop --hidden";
    }
    {
      name = "gcdemu";
      command = "${pkgs.gcdemu}/bin/gcdemu";
    }
    {
      name = "telegram";
      command = "${pkgs.tdesktop}/bin/telegram-desktop -autostart";
    }
    {
      name = "thunderbird";
      command = "${pkgs.thunderbird}/bin/thunderbird";
    }
    {
      name = "ulauncher";
      command = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    }
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
    [8 10 14 16 22 24 32 36 40 48 64 72 96 128 192 256 480 512]));
}
