{ pkgs, ... }:
netns: pkg:
pkgs.stdenv.mkDerivation {
  inherit (pkg) pname version;
  phases = [ "installPhase" ];
  installPhase = ''
    # Link everything except bin folder
    mkdir -p $out/bin
    for F in ${pkg}/*; do
      [ "$(basename $F)" != "bin" ] && ln -s $F $out/$(basename $F)
    done

    # Wrap everything in bin folder
    for F in ${pkg}/bin/*; do
      [ -f "$F" ] || continue
      cat > $out/bin/$(basename $F) <<EOF
    #!/bin/sh
    /run/wrappers/bin/netns-exec-dbus ${netns} $F \$*
    EOF
      chmod +x $out/bin/$(basename $F)
    done
  '';
}
