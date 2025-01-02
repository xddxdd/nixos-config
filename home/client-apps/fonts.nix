{ osConfig, config, ... }:
{
  # To make Steam recognize Chinese fonts
  fonts.fontconfig.defaultFonts = osConfig.fonts.fontconfig.defaultFonts;
  xdg.dataFile."fonts".source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
}
