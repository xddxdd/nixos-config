{ LT, lib, ... }:
let
  src = LT.sources.ulauncher-theme-trans.src;
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
