{ config, pkgs, ... }:

{
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.libsForQt5.breeze-qt5;
      name = "breeze_cursor";
      size = 24;
    };
    font = {
      package = pkgs.ubuntu_font_family;
      name = "Ubuntu";
      size = 10;
    };
    iconTheme = {
      package = pkgs.breeze-icons;
      name = "breeze-dark";
    };
    theme = {
      package = pkgs.breeze-gtk;
      name = "Breeze-Dark";
    };
  };
}
