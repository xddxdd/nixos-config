{ pkgs, ... }:
{
  xdg.dataFile = {
    "fcitx5/themes".source = "${pkgs.nur-xddxdd.fcitx5-breeze}/share/fcitx5/themes";
  };
}
