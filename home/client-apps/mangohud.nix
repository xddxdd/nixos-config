{ osConfig, pkgs, ... }:
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

    settingsPerApplication = {
      mpv = {
        no_display = true;
      };
    };
  };
}
