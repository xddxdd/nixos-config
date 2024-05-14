{ pkgs, config, ... }:
let
  mangohudForCurrentKernel = pkgs.mangohud.override {
    inherit (config.boot.kernelPackages.nvidia_x11.settings) libXNVCtrl;
  };
in
{
  programs.steam.enable = true;
  environment.systemPackages = [ mangohudForCurrentKernel ];
  # https://www.reddit.com/r/NixOS/comments/11d76bb/comment/jaqzwyt
  hardware.opengl = {
    extraPackages = [ mangohudForCurrentKernel ];
    extraPackages32 = [ mangohudForCurrentKernel ];
  };
}
