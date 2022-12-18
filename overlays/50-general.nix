{ inputs, ... }:

final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
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
  flexget = prev.flexget.overrideAttrs (old: {
    propagatedBuildInputs = with prev.python3Packages; old.propagatedBuildInputs ++ [
      cloudscraper
    ];
  });
  jellyfin = prev.jellyfin.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/jellyfin-volume-normalization.patch
    ];
  });
  jellyfin-media-player = prev.jellyfin-media-player.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (with final; [ makeWrapper ]);
    postFixup = (old.postFixup or "") + ''
      wrapProgram "$out/bin/jellyfinmediaplayer" \
        --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib/"
    '';
  });
  matrix-synapse = prev.matrix-synapse.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/matrix-synapse-listen-unix.patch
    ];
  });
  nix-top = prev.nix-top.overrideAttrs (old: {
    postPatch = (old.postInstall or "") + ''
      substituteInPlace nix-top --replace "/tmp" "/var/cache/nix"
    '';
  });
  oh-my-zsh = prev.oh-my-zsh.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/oh-my-zsh-disable-compdump.patch
    ];
  });
  openvpn = prev.openvpn.overrideAttrs (old: {
    inherit (sources.openvpn) version src;
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (with final; [ autoreconfHook ]);
    buildInputs = (old.buildInputs or [ ]) ++ (with final; [
      docutils
      libcap_ng
      libnl
      lz4
    ]);
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-dco"
    ];
  });
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
  transmission = prev.transmission.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mv $out/share/transmission/web/index.html $out/share/transmission/web/index.original.html
      cp -r ${sources.transmission-web-control.src}/src/* $out/share/transmission/web/
    '';
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
  zsh-autopair = prev.zsh-autopair.overrideAttrs (old: {
    inherit (sources.zsh-autopair) version src;
    installPhase = ''
      mkdir -p $out/share/zsh/zsh-autopair
      cp -r *.zsh $out/share/zsh/zsh-autopair/
    '';
  });
}
