{inputs, ...}: final: prev: let
  sources = final.callPackage ../helpers/_sources/generated.nix {};
in rec {
  bird = final.bird-babel-rtt;
  brlaser = prev.brlaser.overrideAttrs (old: {
    inherit (sources.brlaser) version src;
  });
  calibre = prev.calibre.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        sed -i "/MimeType=/d" $out/share/applications/*.desktop
      '';
  });
  drone = prev.drone.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ../patches/drone-server-listen-unix.patch
      ];
  });
  drone-vault = prev.drone-vault.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ../patches/drone-vault-listen-unix.patch
      ];
  });
  flexget = prev.flexget.overrideAttrs (old: {
    propagatedBuildInputs = with prev.python3Packages;
      old.propagatedBuildInputs
      ++ [
        cloudscraper
      ];
  });
  jellyfin-media-player = prev.jellyfin-media-player.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with final; [makeWrapper]);
    postFixup =
      (old.postFixup or "")
      + ''
        wrapProgram "$out/bin/jellyfinmediaplayer" \
          --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib/"
      '';
  });
  lemmy-server = prev.lemmy-server.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        (final.fetchpatch {
          name = "fix-db-migrations.patch";
          url = "https://gist.githubusercontent.com/matejc/9be474fa581c1a29592877ede461f1f2/raw/83886917153fcba127b43d9a94a49b3d90e635b3/fix-db-migrations.patch";
          sha256 = "1llwkq014vh78kjr4ic1sjsl5a5k8dgfswzxm97w3yfn0npkz32r";
        })
      ];
  });
  looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with final; [makeWrapper]);
    postFixup =
      (old.postFixup or "")
      + ''
        wrapProgram $out/bin/looking-glass-client --unset WAYLAND_DISPLAY

        # Do not start terminal for looking glass client
        sed "/Terminal=true/d" $out/share/applications/looking-glass-client.desktop > looking-glass-client.desktop
        rm -rf $out/share/applications
        mkdir -p $out/share/applications
        mv looking-glass-client.desktop $out/share/applications/looking-glass-client.desktop
      '';
  });
  mailutils = prev.mailutils.overrideAttrs (old: {
    doCheck = false;
  });
  matrix-synapse = prev.matrix-synapse.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ../patches/matrix-synapse-listen-unix.patch
      ];
  });
  mtdutils = prev.mtdutils.overrideAttrs (old: {
    postFixup =
      (old.postFixup or "")
      + ''
        sed -i "s#/bin/mount#${final.util-linux}/bin/mount#g" $out/bin/mount.ubifs
      '';
  });
  nix-top = prev.nix-top.overrideAttrs (old: {
    postPatch =
      (old.postInstall or "")
      + ''
        substituteInPlace nix-top --replace "/tmp" "/var/cache/nix"
      '';
  });
  oh-my-zsh = prev.oh-my-zsh.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ../patches/oh-my-zsh-disable-compdump.patch
      ];
  });
  openvpn = prev.openvpn.overrideAttrs (old: {
    inherit (sources.openvpn) version src;
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with final; [autoreconfHook]);
    buildInputs =
      (old.buildInputs or [])
      ++ (with final; [
        docutils
        libcap_ng
        libnl
        lz4
      ]);
    configureFlags =
      (old.configureFlags or [])
      ++ [
        "--enable-dco"
      ];
  });
  phpWithExtensions = prev.php.withExtensions ({
    enabled,
    all,
  }:
    with all;
      enabled
      ++ [
        apcu
        bz2
        ctype
        curl
        dom
        event
        exif
        ffi
        ftp
        gd
        gettext
        gmp
        iconv
        imagick
        maxminddb
        mbstring
        memcached
        mysqli
        mysqlnd
        openssl
        pdo
        pdo_mysql
        pdo_pgsql
        pdo_sqlite
        pgsql
        protobuf
        readline
        redis
        sockets
        sodium
        sqlite3
        xml
        # FIXME: Disabled for build failure
        # yaml
        zip
        zlib
      ]);
  prismlauncher = prev.prismlauncher.override {
    jdks =
      (with final; [
        openjdk8
        openjdk11
        openjdk17
      ])
      ++ (with final.openj9-ibm-semeru; [
        jdk-bin-11
        jdk-bin-17
        jdk-bin-8
      ]);
  };
  qbittorrent-enhanced-edition = prev.qbittorrent-enhanced-edition.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches =
      (old.patches or [])
      ++ [
        ../patches/qbittorrent-return-success-on-dup-torrent.patch
      ];
  });
  qbittorrent-enhanced-edition-nox = prev.qbittorrent-enhanced-edition-nox.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches =
      (old.patches or [])
      ++ [
        ../patches/qbittorrent-return-success-on-dup-torrent.patch
      ];
  });
  tdesktop = prev.tdesktop.overrideAttrs (old: {
    enableParallelBuilding = true;
    postPatch =
      old.postPatch
      + ''
        for ttf in Telegram/lib_ui/fonts/*.ttf; do
            rm $ttf
            touch $ttf
        done
        sed -i 's/DemiBold/Bold/g' Telegram/lib_ui/ui/style/style_core_font.cpp
      '';
  });
  tinc_pre = prev.tinc_pre.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [final.miniupnpc];
    configureFlags =
      (old.configureFlags or [])
      ++ [
        "--enable-miniupnpc"
      ];
  });
  ulauncher = prev.ulauncher.overrideAttrs (old: {
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ (with prev; [
        gobject-introspection
      ]);

    propagatedBuildInputs = with prev.python3Packages;
      old.propagatedBuildInputs
      ++ [
        fuzzywuzzy
        pint
        pytz
        simpleeval
      ];
  });
  zsh-autopair = prev.zsh-autopair.overrideAttrs (old: {
    inherit (sources.zsh-autopair) version src;
    installPhase = ''
      mkdir -p $out/share/zsh/zsh-autopair
      cp -r *.zsh $out/share/zsh/zsh-autopair/
    '';
  });
}
