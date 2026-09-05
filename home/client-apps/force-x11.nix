{
  pkgs,
  lib,
  LT,
  ...
}:
let
  mkForceX11 =
    package:
    lib.hiPrio (
      pkgs.runCommand "${package.name}-force-x11" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin
        for F in ${package}/bin/*; do
          [ -f "$F" ] || continue
          makeWrapper "$F" $out/bin/$(basename "$F") ${LT.constants.forceX11WrapperArgs}
        done
      ''
    );
in
{
  home.packages = builtins.map mkForceX11 (
    with pkgs;
    [
      # keep-sorted start
      apache-directory-studio
      freecad
      thunderbird-bin # Fix auto close on shutdown
      # keep-sorted end
    ]
  );
}
