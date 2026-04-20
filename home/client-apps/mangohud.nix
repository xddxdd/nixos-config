{
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  mangohudForCurrentKernel = pkgs.mangohud.override {
    linuxPackages = osConfig.boot.kernelPackages;
  };
in
{
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    package = mangohudForCurrentKernel;

    settings = lib.mapAttrs (_: lib.mkForce) {
      background_alpha = 0;
      font_size = 16 * (osConfig.lantian.hidpi or 1);
      font_scale = 1;
    };

    settingsPerApplication = {
      mpv.no_display = true;
      zeditor.no_display = true;
    };
  };
}
