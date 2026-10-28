{ pkgs, ... }:
let
  wine' = pkgs.wine-tkg.overrideAttrs (old: {
    prePatch =
      let
        oldPrepatch = old.prePatch or "";
      in
      (if oldPrepatch == null then "" else oldPrepatch)
      + ''
        substituteInPlace "loader/wine.inf.in" --replace-warn \
          'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -a -r"' \
          'HKLM,%CurrentVersion%\RunServices,"winemenubuilder",2,"%11%\winemenubuilder.exe -r"'
      '';

    postFixup = ''
      ln -sf $out/bin/wine $out/bin/wine64
    '';
  });
in
{
  home.packages = [ wine' ];
}
