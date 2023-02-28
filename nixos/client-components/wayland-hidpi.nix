{
  pkgs,
  lib,
  LT,
  config,
  options,
  utils,
  inputs,
  ...
} @ args: let
  consoleFontSize = let
    targetSize = builtins.floor (config.lantian.hidpi * 16);
  in
    if targetSize >= 30
    then 32
    else if targetSize >= 26
    then 28
    else if targetSize >= 23
    then 24
    else if targetSize >= 21
    then 22
    else if targetSize >= 19
    then 20
    else if targetSize >= 17
    then 18
    else if targetSize >= 15
    then 16
    else if targetSize >= 13
    then 14
    else 12;
in {
  options.lantian.hidpi = lib.mkOption {
    type = lib.types.float;
    default = 1;
    description = "HiDPI scaling for Wayland";
  };

  config = {
    # environment.variables = {
    #   GDK_SCALE = "1";
    #   GDK_DPI_SCALE = builtins.toString config.lantian.hidpi;
    #   QT_WAYLAND_FORCE_DPI = builtins.toString (builtins.floor (config.lantian.hidpi * 96));
    # };

    boot.loader.grub.fontSize = consoleFontSize;
    console.packages = with pkgs; [terminus_font];
    console.font = "ter-v${builtins.toString consoleFontSize}n";
  };
}
