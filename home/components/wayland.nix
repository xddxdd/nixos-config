{ config, pkgs, ... }:

let
  electronFlags = pkgs.writeText "electron-flags.conf" ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';
in
{
  xdg.configFile."code-flags.conf".source = electronFlags;
  xdg.configFile."electron-flags.conf".source = electronFlags;
  xdg.configFile."electron14-flags.conf".source = electronFlags;
  xdg.configFile."electron15-flags.conf".source = electronFlags;
}
