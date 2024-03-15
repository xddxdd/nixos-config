{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  xdg.dataFile = {
    "fcitx5/themes".source = "${pkgs.fcitx5-breeze}/share/fcitx5/themes";
  };
}
