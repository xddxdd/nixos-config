{ inputs, nixpkgs, ... }:

let
  lib = nixpkgs.lib;

  awkFormatNginx = builtins.toFile "awkFormat-nginx.awk" ''
    awk -f
    {sub(/^[ \t]+/,"");idx=0}
    /\{/{ctx++;idx=1}
    /\}/{ctx--}
    {id="";for(i=idx;i<ctx;i++)id=sprintf("%s%s", id, "\t");printf "%s%s\n", id, $0}
  '';
in
final: prev: {
  flake = inputs;
  secrets = inputs.secrets;

  # Disable checking nginx.conf
  writers = prev.writers // {
    writeNginxConfig = name: text: final.runCommandLocal name
      {
        inherit text;
        passAsFile = [ "text" ];
        nativeBuildInputs = with final; [ gawk gnused ];
      } ''
      awk -f ${awkFormatNginx} "$textPath" | sed '/^\s*$/d' > $out
    '';
  };

  bind = prev.bind.overrideAttrs (old: rec {
    patches = old.patches ++ [
      # https://github.com/NixOS/nixpkgs/pull/163854/files
      (final.fetchurl {
        url = "https://gitlab.isc.org/isc-projects/bind9/-/commit/b465b29eaf5ad8b8882debff1f993b8288617f22.patch";
        sha256 = "sha256-mjbvGs99Xs44mjMq40NmE0AEPZFETsi6317RR+LngLU=";
      })
    ];
  });
  bird = prev.bird.overrideAttrs (old: rec {
    version = "2.0.8";
    src = prev.fetchurl {
      sha256 = "1xp7f0im1v8pqqx3xqyfkd1nsxk8vnbqgrdrwnwhg8r5xs1xxlhr";
      url = "ftp://bird.network.cz/pub/bird/bird2-2.0.8.tar.gz";
    };
    patches = [
      (nixpkgs + "/pkgs/servers/bird/dont-create-sysconfdir-2.patch")
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
  zoom-us = prev.zoom-us.overrideAttrs (old:
    let
      libs = lib.makeLibraryPath (with final; [
        # $ LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$PWD ldd zoom | grep 'not found'
        alsa-lib
        atk
        cairo
        dbus
        libGL
        fontconfig
        freetype
        gtk3
        gdk-pixbuf
        glib
        pango
        stdenv.cc.cc
        wayland
        xorg.libX11
        xorg.libxcb
        xorg.libXcomposite
        xorg.libXext
        libxkbcommon
        xorg.libXrender
        zlib
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.libXfixes
        xorg.libXtst
        libpulseaudio
      ]);
    in
    {
      postFixup = ''
        # Desktop File
        substituteInPlace $out/share/applications/Zoom.desktop \
          --replace "Exec=/usr/bin/zoom" "Exec=$out/bin/zoom"

        for i in zopen zoom ZoomLauncher; do
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/zoom/$i
        done

        # ZoomLauncher sets LD_LIBRARY_PATH before execing zoom
        wrapProgram $out/opt/zoom/zoom \
          --prefix LD_LIBRARY_PATH ":" ${libs}

        rm $out/bin/zoom
        # Zoom expects "zopen" executable (needed for web login) to be present in CWD. Or does it expect
        # everybody runs Zoom only after cd to Zoom package directory? Anyway, :facepalm:
        # Clear Qt paths to prevent tripping over "foreign" Qt resources.
        # Clear Qt screen scaling settings to prevent over-scaling.
        makeWrapper $out/opt/zoom/ZoomLauncher $out/bin/zoom \
          --run "cd $out/opt/zoom" \
          --unset QML2_IMPORT_PATH \
          --unset QT_PLUGIN_PATH \
          --unset QT_SCREEN_SCALE_FACTORS \
          --set QT_AUTO_SCREEN_SCALE_FACTOR 1 \
          --prefix PATH : ${lib.makeBinPath (with final; [ coreutils glib.dev pciutils procps util-linux ])} \
          --prefix LD_LIBRARY_PATH ":" ${libs}

        # Backwards compatiblity: we used to call it zoom-us
        ln -s $out/bin/{zoom,zoom-us}
      '';
    });
}
