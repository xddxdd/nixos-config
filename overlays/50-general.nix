{ inputs, ... }:
final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
  acme-sh = prev.acme-sh.overrideAttrs (old: {
    postBuild =
      (old.postBuild or "")
      + ''
        sed -i "s/api.gcorelabs.com/api.gcore.com/g" dnsapi/dns_gcore.sh
      '';
  });
  brlaser = prev.brlaser.overrideAttrs (old: {
    inherit (sources.brlaser) version src;
  });
  colmena = prev.colmena.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/colmena-disable-pure-eval.patch ];
  });
  drone = prev.drone.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/drone-server-listen-unix.patch ];

    tags = old.tags ++ [ "nolimit" ];
  });
  knot-dns = prev.knot-dns.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/knot-disable-semantic-check.patch ];
    doCheck = false;
  });
  lidarr = prev.lidarr.overrideAttrs (old: {
    version = builtins.head (final.lib.splitString "/" sources.lidarr-x64.version);
    src = sources.lidarr-x64.src;
  });
  matrix-sliding-sync = prev.matrix-sliding-sync.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/matrix-sliding-sync-listen-unix.patch ];
  });
  matrix-synapse = prev.matrix-synapse.override { inherit matrix-synapse-unwrapped; };
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/matrix-synapse-listen-unix.patch ];
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
  openvpn-with-dco = prev.openvpn.overrideAttrs (old: {
    inherit (sources.openvpn) version src;
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (with final; [ autoreconfHook ]);
    buildInputs =
      (old.buildInputs or [ ])
      ++ (with final; [
        docutils
        libcap_ng
        libnl
        lz4
      ]);
    configureFlags = (old.configureFlags or [ ]) ++ [ "--enable-dco" ];
  });
  phpWithExtensions = prev.php.withExtensions (
    { enabled, all }:
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
      yaml
      zip
      zlib
    ]
  );
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
  prowlarr = prev.prowlarr.overrideAttrs (old: {
    version = builtins.head (final.lib.splitString "/" sources.prowlarr-x64.version);
    src = sources.prowlarr-x64.src;
  });
  qbittorrent-enhanced-edition = prev.qbittorrent-enhanced-edition.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
  });
  qbittorrent-enhanced-edition-nox = prev.qbittorrent-enhanced-edition-nox.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
  });
  radarr = prev.radarr.overrideAttrs (old: {
    version = builtins.head (final.lib.splitString "/" sources.radarr-x64.version);
    src = sources.radarr-x64.src;
  });
  sonarr = prev.sonarr.overrideAttrs (old: {
    version = builtins.head (final.lib.splitString "/" sources.sonarr-x64.version);
    src = sources.sonarr-x64.src;
  });
  # sshfs = prev.sshfs.override {
  #   callPackage = path: args: final.callPackage path (args // {openssh = openssh_hpn;});
  # };
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
    buildInputs = (old.buildInputs or [ ]) ++ [ final.miniupnpc ];
    configureFlags = (old.configureFlags or [ ]) ++ [ "--enable-miniupnpc" ];
  });
  ulauncher = prev.ulauncher.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ (with prev; [ gobject-introspection ]);

    propagatedBuildInputs =
      with prev.python3Packages;
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
