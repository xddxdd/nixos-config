_: {
  stylix.targets = {
    # Having KDE is enough, QT module only supports qtct not kde6
    qt.enable = false;

    firefox = {
      firefoxGnomeTheme.enable = true;
      profileNames = [ "_stylix" ];
    };
    librewolf = {
      firefoxGnomeTheme.enable = true;
      profileNames = [ "_stylix" ];
    };
  };
}
