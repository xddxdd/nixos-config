{
  pkgs,
  lib,
  LT,
  osConfig,
  config,
  inputs,
  ...
}:
let
  calibre-override-desktop = lib.hiPrio (
    pkgs.runCommand "calibre-override-desktop" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      for F in ${pkgs.calibre}/bin/*; do
        [ -f "$F" ] || continue
        makeWrapper "$F" $out/bin/$(basename "$F") ${LT.constants.forceX11WrapperArgs}
      done

      mkdir -p $out/share/applications
      for F in ${pkgs.calibre}/share/applications/*; do
        sed "/MimeType=/d" < "$F" > $out/share/applications/$(basename "$F")
      done
    ''
  );

  jamesdsp-toggle = pkgs.writeShellScriptBin "jamesdsp-toggle" ''
    NEW_STATE=$([ $(${lib.getExe pkgs.jamesdsp} --get master_enable) = "true" ] && echo "false" || echo "true")
    ${lib.getExe pkgs.jamesdsp} --set master_enable=$NEW_STATE
    exit 0
  '';

  wine' = inputs.nix-gaming.packages."${pkgs.system}".wine-tkg.overrideAttrs (old: {
    prePatch = (old.prePatch or "") + ''
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
        # keep-sorted start
        (LT.wrapNetns "tnl-buyvm" deluge)
        (LT.wrapNetns "tnl-buyvm" nur-xddxdd.amule-dlp)
        (LT.wrapNetns "tnl-buyvm" qbittorrent-enhanced)
        (hashcat.override { cudaSupport = true; })
        # error: collision between `/nix/store/2vkk2dnf693fzhlx7v2wn2kcvflgkih9-qqmusic-1.1.5/opt/LICENSE.electron.txt' and `/nix/store/zwgihw847calnxy6ff341l1qkilmn8hm-qq-3.2.2-18394/opt/LICENSE.electron.txt'
        (lib.hiPrio nur-xddxdd.qq)
        (lutris.override { extraPkgs = p: with p; [ xdelta ]; })
        antigravity
        apache-directory-studio
        aria2
        attic-client
        audacious
        brotli
        bzip2
        calibre
        calibre-override-desktop
        cherry-studio
        code-cursor
        colmena
        dbeaver-bin
        distrobox
        ecapture
        exiftool
        feishin
        ffmpeg-full
        filezilla
        freecad
        gcdemu
        gedit
        gimp
        # gopher
        imagemagick
        immich-cli
        jamesdsp
        jamesdsp-toggle
        kdePackages.ark
        kdePackages.isoimagewriter
        # kdePackages.kdenlive
        kdePackages.kpat
        kdePackages.neochat
        kicad
        lbzip2
        libfaketime
        # libreoffice-qt6-fresh
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
        nur-xddxdd.bambu-studio-bin
        nur-xddxdd.bilibili
        # nur-xddxdd.dingtalk
        nur-xddxdd.easycli
        nur-xddxdd.google-earth-pro
        nur-xddxdd.gopherus
        # nur-xddxdd.kikoplay
        nur-xddxdd.lantianCustomized.materialgram
        nur-xddxdd.ncmdump-rs
        nur-xddxdd.qqmusic
        # nur-xddxdd.qqsp
        nur-xddxdd.runpodctl
        nur-xddxdd.space-cadet-pinball-full-tilt
        nur-xddxdd.wechat-uos-sandboxed
        nvfetcher
        openscad
        openscad-lsp
        p7zip
        parsec-bin
        payload-dumper-go
        piliplus
        powertop
        prismlauncher
        pwgen
        qrcp
        quasselClient
        rar
        rustdesk
        steam-run
        synadm
        tigervnc
        tor-browser
        ulauncher
        unar
        ventoy-full
        virt-manager
        vlc
        vopono
        vscode
        windsurf
        wine'
        winetricks
        wpsoffice
        xca
        xdg-ninja
        yubioath-flutter
        zed-editor
        zoom-us
        # keep-sorted end
      ]
      ++ lib.optionals (osConfig.networking.hostName != "lt-dell-wyse") [ nur-xddxdd.svp_4_6 ]
    );

  programs.nix-index.enable = true;
  programs.nix-index.symlinkToCacheHome = true;
  programs.nix-index-database.comma.enable = true;

  services.remmina = {
    enable = true;
    addRdpMimeTypeAssoc = true;
    systemdService.enable = false;
  };

  # Tidy home directory
  nix.enable = lib.mkForce false; # nix will be provided by system config
  home.sessionVariables = {
    # keep-sorted start
    CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
    WINEPREFIX = "${config.xdg.dataHome}/wine";
    # keep-sorted end
  };
}
