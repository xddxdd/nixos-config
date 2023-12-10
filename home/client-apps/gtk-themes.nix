{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  gtk = {
    enable = true;
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

  home.pointerCursor = {
    package = pkgs.sam-toki-mouse-cursors;
    name = "STMCS-601-GenshinFurina";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
  };
}
