{ lib, ... }:
{
  xdg.configFile = lib.listToAttrs (
    lib.mapAttrsToList (name: type: {
      name = "ulauncher/user-themes/elementary-dark-trans/${name}";
      value.source = ./themes/elementary-dark-trans + "/${name}";
    }) (builtins.readDir ./themes/elementary-dark-trans)
  );
}
