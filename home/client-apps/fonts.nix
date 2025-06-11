{ config, ... }:
{
  # To make Steam recognize Chinese fonts
  xdg.dataFile."fonts".source =
    config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
}
