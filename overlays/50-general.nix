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
      ../patches/dex-2fa.patch
    ];
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace server/handlers.go \
          --replace-fail '&& !authReq.ForceApprovalPrompt' ""
      '';
    vendorHash = "sha256-PUeMs6VZSB5YMc0MRen7Jmdi2eFbEQsHix/VzeydYoc=";
    doCheck = false;
  });
  flaresolverr = prev.flaresolverr.overrideAttrs (_old: {
    inherit (sources.flaresolverr) version src;
  });
  gcdemu = prev.gcdemu.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ final.libappindicator-gtk3 ];
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
  qbittorrent-enhanced = prev.qbittorrent-enhanced.overrideAttrs (old: {
    # Sonarr retries with different release when adding existing torrent
    patches = (old.patches or [ ]) ++ [ ../patches/qbittorrent-return-success-on-dup-torrent.patch ];
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
  zsh-autopair = prev.zsh-autopair.overrideAttrs (_old: {
    installPhase = ''
      mkdir -p $out/share/zsh/zsh-autopair
      cp -r *.zsh $out/share/zsh/zsh-autopair/
    '';
  });
}
