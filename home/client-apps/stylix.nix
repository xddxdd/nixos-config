_: {
  stylix = {
    targets = {
      firefox = {
        colorTheme.enable = true;
        profileNames = [ "lantian" ];
      };
      librewolf = {
        colorTheme.enable = true;
        profileNames = [ "lantian" ];
      };
      kde.useWallpaper = false;
      # Qt theming stays on NixOS-side (targets.qt.platform = "kde"); the HM
      # qt module would otherwise emit the "platform other than 'qtct'"
      # warning, and its kvantum/qtct config is inert under "kde".
      qt.enable = false;
    };
  };

  home.pointerCursor = {
    # Tidy home folder
    enable = true;
    dotIcons.enable = false;
  };
}
