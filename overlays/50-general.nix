_: final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
  colmena = prev.colmena.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/colmena-combine-logs-same-node.patch
      ../patches/colmena-verbose-single-node.patch
    ];
  });
  dex-oidc = prev.dex-oidc.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/dex-glob-match-redirect-uri.patch
      ../patches/dex-skip-approval-screen.patch
    ];
    vendorHash = "sha256-FCcIKej106jDLvPdsYBtpB61QfD2nQpXwVpOtc2WdW0=";
    doCheck = false;
  });
  dump1090-fa = prev.dump1090-fa.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/dump1090-gcc15-fix.patch
    ];
  });
  hydra = prev.hydra.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/hydra-enable-delete-jobset.patch ];
  });
  knot-dns = prev.knot-dns.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/knot-disable-semantic-check.patch ];
    doCheck = false;
  });
  matrix-synapse = prev.matrix-synapse.override { inherit matrix-synapse-unwrapped; };
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/matrix-synapse-listen-unix.patch ];
    doCheck = false;
    doInstallCheck = false;
  });
  mpv-unwrapped = prev.mpv-unwrapped.override {
    inherit (final.nur-xddxdd.lantianCustomized) ffmpeg;
  };
  netavark = prev.netavark.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/netavark-disable-conntrack.patch ];
    doCheck = false;
  });
  open5gs = prev.open5gs.overrideAttrs (_old: {
    inherit (sources.open5gs) version src;
    diameter = sources.open5gs-freediameter.src;
  });
  open-webui = prev.open-webui.overridePythonAttrs (old: {
    dependencies = (old.dependencies or [ ]) ++ old.optional-dependencies.all;
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
      ++ (with final.nur-xddxdd.openj9-ibm-semeru; [
        jdk-bin-11
        jdk-bin-17
        jdk-bin-8
      ]);
  };
  qbittorrent-enhanced-nox = prev.qbittorrent-enhanced-nox.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
  });
  qbittorrent-nox = prev.qbittorrent-nox.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
  });
  ulauncher = prev.ulauncher.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ (with prev; [ gobject-introspection ]);

    propagatedBuildInputs =
      with prev.python3Packages;
      old.propagatedBuildInputs
      ++ [
        # keep-sorted start
        faker
        fuzzywuzzy
        pint
        pytz
        simpleeval
        # keep-sorted end
      ];
  });
  yt-dlp = prev.yt-dlp.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      # Modified from https://github.com/yt-dlp/yt-dlp/issues/14498#issuecomment-3391106164
      ../patches/yt-dlp-replace-bilibili-hostname.patch
    ];
  });
  zerotierone = prev.zerotierone.override {
    enableUnfree = true;
  };
}
