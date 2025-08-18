{
  config,
  lib,
  osConfig,
  ...
}:
{
  # To make Steam recognize Chinese fonts
  xdg.dataFile."fonts".source =
    config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";

  # https://keqingrong.cn/blog/2019-10-01-how-to-display-all-chinese-characters-on-the-computer/
  fonts.fontconfig.defaultFonts = lib.mkForce osConfig.fonts.fontconfig.defaultFonts;
}
