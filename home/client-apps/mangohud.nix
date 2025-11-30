{
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  mangohudForCurrentKernel = pkgs.mangohud.override {
    inherit (osConfig.boot.kernelPackages.nvidia_x11.settings) libXNVCtrl;
  };
in
{
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    package = mangohudForCurrentKernel;

    settings = lib.mapAttrs (_: lib.mkForce) {
      background_alpha = 0;
      font_size = 16 * (osConfig.lantian.hidpi or 1);
      font_scale = 1;
    };

    settingsPerApplication = {
      mpv = {
        no_display = true;
      };
    };
  };
}
