{
  pkgs,
  lib,
  LT,
  config,
  osConfig,
  utils,
  inputs,
  ...
}@args:
let
  calibre-override-desktop = lib.hiPrio (
    pkgs.runCommand "calibre-override-desktop" { } ''
      mkdir -p $out/share/applications
      for F in ${pkgs.calibre}/share/applications/*; do
        sed "/MimeType=/d" < "$F" > $out/share/applications/$(basename "$F")
      done
    ''
  );

  jamesdsp-toggle = pkgs.writeShellScriptBin "jamesdsp-toggle" ''
    NEW_STATE=$([ $(${pkgs.jamesdsp}/bin/jamesdsp --get master_enable) = "true" ] && echo "false" || echo "true")
    ${pkgs.jamesdsp}/bin/jamesdsp --set master_enable=$NEW_STATE
    exit 0
  '';

  jellyfin-media-player-wrapped = lib.hiPrio (
    pkgs.runCommand "jellyfin-media-player-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; }
      ''
        mkdir -p $out/bin
        makeWrapper \
          ${pkgs.jellyfin-media-player}/bin/jellyfinmediaplayer \
          $out/bin/jellyfinmediaplayer \
          --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib/"
      ''
  );

  prismlauncher-wrapped = lib.hiPrio (
    pkgs.runCommand "prismlauncher-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
      mkdir -p $out/share/applications
      for F in ${pkgs.prismlauncher}/share/applications/*; do
        sed "s#application/zip;##g" < "$F" > $out/share/applications/$(basename "$F")
      done
    ''
  );

  step-cli-wrapped = pkgs.writeShellScriptBin "step" ''
    export STEPPATH="$HOME/.local/share/step"
    exec ${pkgs.step-cli}/bin/step "$@"
  '';

  vscode-wrapped = lib.hiPrio (
    pkgs.runCommand "vscode-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper \
        ${pkgs.vscode}/bin/code \
        $out/bin/code \
        --add-flags "--disable-gpu"
    ''
  );
in
{
  home.packages =
    with pkgs;
    (
      [
        # error: collision between `/nix/store/2vkk2dnf693fzhlx7v2wn2kcvflgkih9-qqmusic-1.1.5/opt/LICENSE.electron.txt' and `/nix/store/zwgihw847calnxy6ff341l1qkilmn8hm-qq-3.2.2-18394/opt/LICENSE.electron.txt'
        (lib.hiPrio qq)
        (LT.wrapNetns "wg-lantian" amule-dlp)
        (LT.wrapNetns "wg-lantian" deluge)
        (LT.wrapNetns "wg-lantian" qbittorrent-enhanced-edition)
        (lutris.override { extraPkgs = p: with p; [ xdelta ]; })
        appimage-run
        aria
        audacious
        baidunetdisk
        baidupcs-go
        bilibili
        brotli
        bzip2
        calibre
        calibre-override-desktop
        cloudpan189-go
        colmena
        comma
        dbeaver
        dingtalk
        discord
        discord-canary
        distrobox
        exiftool
        fractal
        ffmpeg-full
        filezilla
        gcdemu
        gedit
        gimp
        google-earth-pro
        gopherus
        imagemagick
        jamesdsp
        jamesdsp-toggle
        jellyfin-media-player
        jellyfin-media-player-wrapped
        kdenlive
        lantianCustomized.attic-telnyx-compatible
        lbzip2
        libfaketime
        librewolf
        libsForQt5.ark
        libsForQt5.kpat
        linphone
        macchanger
        matrix-synapse-tools.synadm
        mediainfo
        megatools
        newsflash
        nvfetcher
        openvpn
        p7zip
        parsec-bin
        payload-dumper-go
        powertop
        prismlauncher
        prismlauncher-wrapped
        pwgen
        qqmusic
        quasselClient
        rar
        remmina
        space-cadet-pinball-full-tilt
        steam-run
        step-cli-wrapped
        tdesktop
        tigervnc
        transmission-qt
        transmission-remote-gtk
        ulauncher
        unar
        vagrant
        virt-manager
        vopono
        vscode
        vscode-wrapped
        wechat-uos
        winetricks
        wineWowPackages.stable
        wpsoffice
        xca
        yt-dlp
        yubikey-manager-qt
        zoom-us
      ]
      ++ lib.optionals (osConfig.networking.hostName != "lt-dell-wyse") [ svp ]
    );

  xdg.configFile = LT.gui.autostart (
    (lib.optionals (osConfig.networking.hostName == "lt-hp-omen") [
      {
        name = "discord";
        command = "${pkgs.discord}/bin/discord --start-minimized";
      }
      {
        name = "discord-canary";
        command = "${pkgs.discord-canary}/bin/discordcanary --start-minimized";
      }
      {
        name = "fractal";
        command = "${pkgs.fractal}/bin/fractal --hidden";
      }
      {
        name = "telegram";
        command = "${pkgs.tdesktop}/bin/telegram-desktop -autostart";
      }
      {
        name = "thunderbird";
        command = "${pkgs.thunderbird}/bin/thunderbird";
      }
    ])
    ++ [
      {
        name = "gcdemu";
        command = "${pkgs.gcdemu}/bin/gcdemu";
      }
      {
        name = "ulauncher";
        command = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
      }
    ]
  );

  xdg.dataFile = builtins.listToAttrs (
    lib.flatten (
      builtins.map
        (size: [
          # https://www.reddit.com/r/Genshin_Impact/comments/x73g4p/mikozilla_fireyae/
          {
            name = "icons/hicolor/${builtins.toString size}x${builtins.toString size}/apps/firefox.png";
            value.source =
              if size < 48 then
                LT.gui.resizeIcon size ../files/mikozilla-fireyae.png
              else
                LT.gui.resizeIcon size ../files/mikozilla-fireyae-petals.png;
          }
        ])
        [
          8
          10
          14
          16
          22
          24
          32
          36
          40
          48
          64
          72
          96
          128
          192
          256
          480
          512
        ]
    )
  );
}
