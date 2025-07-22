{
  pkgs,
  lib,
  LT,
  osConfig,
  inputs,
  config,
  ...
}:
let
  calibre-override-desktop = lib.hiPrio (
    pkgs.runCommand "calibre-override-desktop" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      for F in ${pkgs.calibre}/bin/*; do
        [ -f "$F" ] || continue
        makeWrapper "$F" $out/bin/$(basename "$F") \
          --set QT_QPA_PLATFORM xcb \
          --set XDG_SESSION_TYPE x11 \
          --set GTK_IM_MODULE fcitx \
          --set QT_IM_MODULE fcitx
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

  # Fix auto close on shutdown
  thunderbird-wrapped = lib.hiPrio (
    pkgs.runCommand "thunderbird-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper \
        ${pkgs.thunderbird}/bin/thunderbird \
        $out/bin/thunderbird \
        --set WAYLAND_DISPLAY ""
    ''
  );

  wine' = inputs.nix-gaming.packages."${pkgs.system}".wine-tkg.overrideAttrs (old: {
    prePatch =
      (old.prePatch or "")
      + ''
        substituteInPlace "loader/wine.inf.in" --replace-warn \
          'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -a -r"' \
          'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -r"'
      '';

    postFixup = ''
      ln -sf $out/bin/wine $out/bin/wine64
    '';
  });
in
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  home.packages =
    with pkgs;
    (
      [
        (hashcat.override { cudaSupport = true; })
        # error: collision between `/nix/store/2vkk2dnf693fzhlx7v2wn2kcvflgkih9-qqmusic-1.1.5/opt/LICENSE.electron.txt' and `/nix/store/zwgihw847calnxy6ff341l1qkilmn8hm-qq-3.2.2-18394/opt/LICENSE.electron.txt'
        (lib.hiPrio nur-xddxdd.qq)
        (LT.wrapNetns "tnl-buyvm" deluge)
        (LT.wrapNetns "tnl-buyvm" nur-xddxdd.amule-dlp)
        (LT.wrapNetns "tnl-buyvm" qbittorrent-enhanced)
        (lutris.override { extraPkgs = p: with p; [ xdelta ]; })
        aria
        attic-client
        audacious
        brotli
        bzip2
        calibre
        calibre-override-desktop
        code-cursor
        colmena
        dbeaver-bin
        distrobox
        exiftool
        feishin
        ffmpeg-full
        filezilla
        gcdemu
        gedit
        gimp
        imagemagick
        immich-cli
        jamesdsp
        jamesdsp-toggle
        jellyfin-media-player
        jellyfin-media-player-wrapped
        kdePackages.ark
        kdePackages.kdenlive
        kdePackages.kpat
        kdePackages.neochat
        kiro
        lbzip2
        libfaketime
        libreoffice-qt6-fresh
        linphone
        lx-music-desktop
        macchanger
        mediainfo
        megatools
        microcom
        moonlight-qt
        nur-xddxdd.adspower
        nur-xddxdd.baidunetdisk
        nur-xddxdd.baidupcs-go
        nur-xddxdd.bilibili
        nur-xddxdd.dingtalk
        nur-xddxdd.google-earth-pro
        nur-xddxdd.gopherus
        nur-xddxdd.kikoplay
        nur-xddxdd.lantianCustomized.materialgram
        nur-xddxdd.ncmdump-rs
        nur-xddxdd.qqmusic
        nur-xddxdd.qqsp
        nur-xddxdd.runpodctl
        nur-xddxdd.space-cadet-pinball-full-tilt
        nur-xddxdd.wechat-uos-sandboxed
        nvfetcher
        p7zip
        parsec-bin
        payload-dumper-go
        pilipalax
        powertop
        prismlauncher
        prismlauncher-wrapped
        pwgen
        quasselClient
        rar
        steam-run
        synadm
        thunderbird-wrapped
        tigervnc
        transmission_4-qt
        transmission-remote-gtk
        ulauncher
        unar
        ventoy-full
        virt-manager
        vlc
        vopono
        vscode
        wine'
        winetricks
        wpsoffice
        xca
        yt-dlp
        yubioath-flutter
        zoom-us
      ]
      ++ lib.optionals (osConfig.networking.hostName != "lt-dell-wyse") [ nur-xddxdd.svp ]
    );

  home.sessionVariables = {
    WINEPREFIX = "${config.xdg.dataHome}/wine";
  };

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
        command = "/etc/profiles/per-user/lantian/bin/discord --start-minimized";
      }
      {
        name = "vesktop";
        command = "/etc/profiles/per-user/lantian/bin/vesktop --start-minimized";
      }
      {
        name = "materialgram";
        command = "${pkgs.nur-xddxdd.lantianCustomized.materialgram}/bin/materialgram -autostart";
      }
      {
        name = "neochat";
        command = "${pkgs.kdePackages.neochat}/bin/neochat";
      }
      {
        name = "steam";
        command = "${pkgs.steam}/bin/steam -silent";
      }
      {
        name = "thunderbird";
        command = "${thunderbird-wrapped}/bin/thunderbird";
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
