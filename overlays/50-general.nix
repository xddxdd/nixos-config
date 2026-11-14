{ inputs, ... }:
final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
rec {
  # keep-sorted start block=yes
  # attic-server reuses this derivation with a different crate selection.
  attic-client = prev.attic-client.overrideAttrs (
    old:
    prev.lib.optionalAttrs (builtins.elem "--package=attic-client" old.cargoBuildFlags) {
      patches = (old.patches or [ ]) ++ [ ../patches/attic-client-nar-backpressure.patch ];
    }
  );
  calibre = prev.calibre.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/calibre-page-count-shutdown.patch ];
  });
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
    vendorHash = "sha256-7T4svxdzKsSQup1Ls43bK+l/xMgxL4mmQQ7Ck3WoKRk=";
    doCheck = false;
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
    doCheck = false;
    patches = (old.patches or [ ]) ++ [
      ../patches/hydra-protect-private-project.patch
      ../patches/hydra-oidc-optional-nbf.patch
      ../patches/hydra-oidc-allow-unverified-email.patch
      ../patches/hydra-topbar-queue-links.patch
      ../patches/hydra-evaluation-command-timeout.patch
      ../patches/hydra-disable-build-output-downloads.patch
    ];
  });
  # Systemd socket activation support, from https://github.com/esnet/iperf/pull/1171
  iperf3 = prev.iperf3.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/iperf3-socket-activation.patch ];
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.autoreconfHook ];
    buildInputs = (old.buildInputs or [ ]) ++ [ final.systemdMinimal ];
  });
  knot-dns = prev.knot-dns.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/knot-disable-semantic-check.patch ];
    doCheck = false;
  });
  matrix-synapse = prev.matrix-synapse.override { inherit matrix-synapse-unwrapped; };
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/matrix-synapse-listen-unix.patch
      ../patches/matrix-synapse-dns-ephemeral-source.patch
    ];
    doCheck = false;
    doInstallCheck = false;
  });
  mpv-unwrapped = prev.mpv-unwrapped.override {
    ffmpeg =
      if final.stdenv.hostPlatform.isx86_64 then
        final.callPackage (inputs.secrets + "/pkgs/b6cdd51f4ca52153") { }
      else
        final.ffmpeg;
  };
  netavark = prev.netavark.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/netavark-disable-conntrack.patch ];
    doCheck = false;
  });
  obs-studio-plugins = prev.obs-studio-plugins // {
    obs-noise = prev.obs-studio-plugins.obs-noise.overrideAttrs (old: {
      # GCC 15 diagnoses a discarded const qualifier and the OBS plugin helper
      # adds -Werror
      NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=discarded-qualifiers";
    });
  };
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
  sonarr = prev.sonarr.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/sonarr-chinese-numbering.patch ];
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
