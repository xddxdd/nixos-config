{ inputs, ... }:
final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
  pkgs_latest = inputs.nixpkgs-latest.legacyPackages."${final.system}";
in
rec {
  inherit (pkgs_latest) flaresolverr;

  acme-sh = prev.acme-sh.overrideAttrs (old: {
    postBuild =
      (old.postBuild or "")
      + ''
        sed -i "s/api.gcorelabs.com/api.gcore.com/g" dnsapi/dns_gcore.sh
      '';
  });
  brlaser = prev.brlaser.overrideAttrs (_old: {
    inherit (sources.brlaser) version src;
  });
  colmena = prev.colmena.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/colmena-disable-pure-eval.patch ];
  });
  drone = prev.drone.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/drone-server-listen-unix.patch ];

    tags = old.tags ++ [ "nolimit" ];
  });
  flexget = prev.flexget.overrideAttrs (old: {
    propagatedBuildInputs = with final.python3Packages; old.propagatedBuildInputs ++ [ cloudscraper ];
  });
  knot-dns = prev.knot-dns.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/knot-disable-semantic-check.patch ];
    doCheck = false;
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
  qbittorrent-enhanced-edition = prev.qbittorrent-enhanced-edition.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
  });
  qbittorrent-enhanced-edition-nox = prev.qbittorrent-enhanced-edition-nox.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
  });
  # sshfs = prev.sshfs.override {
  #   callPackage = path: args: final.callPackage path (args // {openssh = openssh_hpn;});
  # };
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
  zsh-autopair = prev.zsh-autopair.overrideAttrs (_old: {
    inherit (sources.zsh-autopair) version src;
    installPhase = ''
      mkdir -p $out/share/zsh/zsh-autopair
      cp -r *.zsh $out/share/zsh/zsh-autopair/
    '';
  });
}
