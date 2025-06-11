{
  lib,
  config,
  ...
}:
{
  gtk = {
    enable = true;
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

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
  };

  home.file."${config.gtk.gtk2.configLocation}".force = lib.mkForce true;
  xdg.configFile."gtk-3.0/settings.ini".force = lib.mkForce true;
  xdg.configFile."gtk-4.0/settings.ini".force = lib.mkForce true;
}
