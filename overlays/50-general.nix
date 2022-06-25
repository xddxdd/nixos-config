{ inputs, lib, ... }:

final: prev: rec {
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
  rage = prev.stdenv.mkDerivation rec {
    name = "rage";
    version = prev.age.version;

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${prev.age}/bin/age $out/bin/rage
      ln -s ${prev.age}/bin/age-keygen $out/bin/rage-keygen
    '';
  };
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
  ulauncher = prev.ulauncher.overrideAttrs (old: {
    propagatedBuildInputs = with prev.python3Packages; old.propagatedBuildInputs ++ [
      fuzzywuzzy
      pint
      pytz
      simpleeval
    ];

    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.makeWrapper ];

    preFixup = old.preFixup + ''
      makeWrapperArgs+=(
        --set XDG_DATA_DIRS "/run/current-system/sw/share"
      )
    '';
  });
}
