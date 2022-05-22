{ pkgs, lib, config, options, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  options.lantian.wayland-hidpi = lib.mkOption {
    type = lib.types.float;
    default = 1;
    description = "HiDPI scaling for Wayland";
  };

  config.environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = builtins.toString config.lantian.wayland-hidpi;
    QT_WAYLAND_FORCE_DPI = builtins.toString (builtins.floor (config.lantian.wayland-hidpi * 96));
  };
}
