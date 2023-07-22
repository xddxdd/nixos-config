{inputs, ...}: final: prev: let
  sources = final.callPackage ../helpers/_sources/generated.nix {};
in rec {
  bird = final.bird-babel-rtt;
  brlaser = prev.brlaser.overrideAttrs (old: {
    inherit (sources.brlaser) version src;
  });
  drone = prev.drone.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ../patches/drone-server-listen-unix.patch
      ];
  });
  flexget = prev.flexget.overrideAttrs (old: {
    propagatedBuildInputs = with prev.python3Packages;
      old.propagatedBuildInputs
      ++ [
        cloudscraper
      ];
  });
  lemmy-server = prev.lemmy-server.overrideAttrs (old: {
    postPatch = ''
      echo "pub const VERSION: &str = \"${old.version}\";" > "crates/utils/src/version.rs"
    '';
    patches =
      (old.patches or [])
      ++ [
        ../patches/lemmy-disable-private-federation-check.patch
      ];
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
