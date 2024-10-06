{
  pkgs,
  lib,
  LT,
  osConfig,
  inputs,
  ...
}:
let
  audacious-wrapped = lib.hiPrio (
    pkgs.runCommand "audacious-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper \
        ${pkgs.audacious}/bin/audacious \
        $out/bin/audacious \
        --set QT_IM_MODULE fcitx
    ''
  );

  calibre-override-desktop = lib.hiPrio (
    pkgs.runCommand "calibre-override-desktop" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      for F in ${pkgs.calibre}/bin/*; do
        [ -f "$F" ] || continue
        makeWrapper "$F" $out/bin/$(basename "$F") \
          --set QT_QPA_PLATFORM xcb \
          --set XDG_SESSION_TYPE x11
      done

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
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  home.packages =
    with pkgs;
    (
      [
        # error: collision between `/nix/store/2vkk2dnf693fzhlx7v2wn2kcvflgkih9-qqmusic-1.1.5/opt/LICENSE.electron.txt' and `/nix/store/zwgihw847calnxy6ff341l1qkilmn8hm-qq-3.2.2-18394/opt/LICENSE.electron.txt'
        (lib.hiPrio nur-xddxdd.qq)
        (LT.wrapNetns "tnl-buyvm" deluge)
        (LT.wrapNetns "tnl-buyvm" nur-xddxdd.amule-dlp)
        (LT.wrapNetns "tnl-buyvm" nur-xddxdd.qbittorrent-enhanced-edition)
        (lutris.override { extraPkgs = p: with p; [ xdelta ]; })
        aria
        audacious
        audacious-wrapped
        brotli
        bzip2
        calibre
        calibre-override-desktop
        colmena
        dbeaver-bin
        discord
        discord-canary
        distrobox
        exiftool
        ffmpeg-full
        filezilla
        gcdemu
        gedit
        gimp
        imagemagick
        immich-cli
        inputs.nix-gaming.packages."${pkgs.system}".wine-ge
        jamesdsp
        jamesdsp-toggle
        jellyfin-media-player
        jellyfin-media-player-wrapped
        kdenlive
        kdePackages.ark
        kdePackages.kpat
        lbzip2
        libfaketime
        libreoffice-qt6-fresh
        librewolf
        linphone
        macchanger
        matrix-synapse-tools.synadm
        mediainfo
        megatools
        moonlight-qt
        newsflash
        nur-xddxdd.baidunetdisk
        nur-xddxdd.baidupcs-go
        nur-xddxdd.bilibili
        nur-xddxdd.cloudpan189-go
        nur-xddxdd.dingtalk
        nur-xddxdd.google-earth-pro
        nur-xddxdd.gopherus
        nur-xddxdd.inter-knot
        nur-xddxdd.kikoplay
        nur-xddxdd.lantianCustomized.attic-telnyx-compatible
        nur-xddxdd.ncmdump-rs
        nur-xddxdd.qqmusic
        nur-xddxdd.runpodctl
        nur-xddxdd.space-cadet-pinball-full-tilt
        nur-xddxdd.wechat-uos
        nur.repos.yes.mkxp-z
        nvfetcher
        openvpn
        p7zip
        parsec-bin
        payload-dumper-go
        powertop
        prismlauncher
        prismlauncher-wrapped
        pwgen
        quasselClient
        rar
        steam-run
        tdesktop
        tigervnc
        transmission_4-qt
        transmission-remote-gtk
        ulauncher
        unar
        vagrant
        ventoy-full
        virt-manager
        vlc
        vopono
        vscode
        vscode-wrapped
        winetricks
        wpsoffice
        xca
        yt-dlp
        yubikey-manager-qt
        zoom-us
      ]
      ++ lib.optionals (osConfig.networking.hostName != "lt-dell-wyse") [ nur-xddxdd.svp ]
    );

  programs.nix-index.enable = true;
  programs.nix-index.symlinkToCacheHome = true;
  programs.nix-index-database.comma.enable = true;

  services.remmina = {
    enable = true;
    addRdpMimeTypeAssoc = true;
    systemdService.enable = false;
  };

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
}
