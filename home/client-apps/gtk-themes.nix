{ pkgs, lib, config, utils, inputs, ... }@args:

{
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
    package = pkgs.libsForQt5.breeze-qt5;
    name = "breeze_cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
  };
}
