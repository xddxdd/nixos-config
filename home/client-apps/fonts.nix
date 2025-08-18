{
  config,
  lib,
  ...
}:
{
  # To make Steam recognize Chinese fonts
  xdg.dataFile."fonts".source =
    config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";

  fonts.fontconfig.enable = lib.mkForce false;
  xdg.configFile."fontconfig".source = config.lib.file.mkOutOfStoreSymlink "/var/empty";
}
