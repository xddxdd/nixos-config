{
  LT,
  lib,
  pkgs,
  ...
}:
let
  src = pkgs.applyPatches {
    src = LT.sources.ulauncher-theme-trans.src;
    postPatch = ''
      sed -i -E 's/border-radius:[^;]*;/border-radius: 0;/' ulauncher-theme-trans-*/theme.css
    '';
  };
  themes = [
    "ulauncher-theme-trans-dark"
    "ulauncher-theme-trans-light"
  ];
in
{
  xdg.configFile = lib.listToAttrs (
    lib.concatMap (
      theme:
      lib.mapAttrsToList (name: type: {
        name = "ulauncher/user-themes/${theme}/${name}";
        value.source = "${src}/${theme}/${name}";
      }) (builtins.readDir "${src}/${theme}")
    ) themes
  );
}
