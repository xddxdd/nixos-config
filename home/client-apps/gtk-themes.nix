{
  pkgs,
  LT,
  config,
  ...
}:
{
  gtk = {
    enable = true;
    font = {
      package = pkgs.ubuntu_font_family;
      name = "Ubuntu";
      size = LT.constants.gui.fontSize;
    };
    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "breeze-dark";
    };
    theme = {
      package = pkgs.kdePackages.breeze-gtk;
      name = "Breeze-Dark";
    };
    gtk2.extraConfig = ''
      gtk-im-module="fcitx"
    '';
    gtk3.extraConfig = {
      gtk-im-module = "fcitx";
    };
    gtk4.extraConfig = {
      gtk-im-module = "fcitx";
    };
  };

  home.pointerCursor = {
    package = pkgs.nur-xddxdd.sam-toki-mouse-cursors;
    name = "STMCS_601_Genshin_Furina";
    # size = builtins.floor (LT.constants.gui.cursorSize * osConfig.config.lantian.hidpi);
    size = LT.constants.gui.cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
  };

  home.file."${config.gtk.gtk2.configLocation}".force = true;
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
}
