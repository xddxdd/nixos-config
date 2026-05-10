_: final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
  # keep-sorted start block=yes
  colmena =
    (prev.colmena.override { inherit (prev.lixPackageSets.latest) nix-eval-jobs; }).overrideAttrs
      (old: {
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
    vendorHash = "sha256-7T4svxdzKsSQup1Ls43bK+l/xMgxL4mmQQ7Ck3WoKRk=";
    doCheck = false;
  });
  dump1090-fa = prev.dump1090-fa.overrideAttrs (old: {
    # Original patch is broken
    patches = [
      (final.fetchpatch2 {
        url = "https://github.com/flightaware/dump1090/commit/93be1da123215e8ac15a0deaffedd480e8899f77.patch";
        hash = "sha256-KSvES/FhMBQ3CRpDF++n2A5sFyRPalNBGUegqQX7UsY=";
      })
    ];
  });
  filezilla = prev.filezilla.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/filezilla-override-pasv-ip-for-zero-ip.patch ];
  });
  handbrake = prev.handbrake.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
    postFixup = ''
      for F in $out/bin/*; do
        wrapProgram "$F" \
          --suffix LD_LIBRARY_PATH : "/run/opengl-driver/lib"
      done
    '';
  });
  hydra = prev.hydra.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/hydra-enable-delete-jobset.patch ];
  });
  inherit (final.nur-xddxdd) bepasty;
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
  n8n = prev.n8n.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/n8n-17954-openai-compatible-reranker.patch ];
  });
  netavark = prev.netavark.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/netavark-disable-conntrack.patch ];
    doCheck = false;
  });
  open-webui = prev.open-webui.overridePythonAttrs (old: {
    dependencies = (old.dependencies or [ ]) ++ old.optional-dependencies.postgres;
  });
  open5gs = prev.open5gs.overrideAttrs (_old: {
    inherit (sources.open5gs) version src;
    diameter = sources.open5gs-freediameter.src;
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
  # keep-sorted end
}
