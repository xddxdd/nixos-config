{ inputs, lib, ... }:

final: prev: rec {
  bird = final.bird-babel-rtt;
  calibre = prev.calibre.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      sed -i "/MimeType=/d" $out/share/applications/*.desktop
    '';
  });
  drone = prev.drone.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/drone-server-listen-unix.patch
    ];
  });
  drone-vault = prev.drone-vault.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/drone-vault-listen-unix.patch
    ];
  });
  jellyfin = prev.jellyfin.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/jellyfin-volume-normalization.patch
    ];
  });
  matrix-synapse = prev.matrix-synapse.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/matrix-synapse-listen-unix.patch
    ];
  });
  # linux-pam = prev.linux-pam.override { withLibxcrypt = true; };
  phpWithExtensions = prev.php.withExtensions ({ enabled, all }: with all; enabled ++ [
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
    yaml
    zip
    zlib
  ]);
  tdesktop = prev.tdesktop.overrideAttrs (old: {
    enableParallelBuilding = true;
    postPatch = old.postPatch + ''
      for ttf in Telegram/lib_ui/fonts/*.ttf; do
          rm $ttf
          touch $ttf
      done
      sed -i 's/DemiBold/Bold/g' Telegram/lib_ui/ui/style/style_core_font.cpp
    '';
  });
  tinc_pre = prev.tinc_pre.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ final.miniupnpc ];
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-miniupnpc"
    ];
  });
  ulauncher = prev.ulauncher.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ (with prev; [
      gobject-introspection
    ]);

    propagatedBuildInputs = with prev.python3Packages; old.propagatedBuildInputs ++ [
      fuzzywuzzy
      pint
      pytz
      simpleeval
    ];
  });
}
