_: {
  stylix.targets = {
    # Having KDE is enough, QT module only supports qtct not kde6
    qt.enable = false;

    firefox = {
      colorTheme.enable = true;
      profileNames = [ "lantian" ];
    };
    librewolf = {
      colorTheme.enable = true;
      profileNames = [ "lantian" ];
    };
  };
}
