{ pkgs, config, ... }:
let
  mangohudForCurrentKernel = pkgs.mangohud.override {
    inherit (config.boot.kernelPackages.nvidia_x11.settings) libXNVCtrl;
  };
in
{
  programs.steam = {
    enable = true;
    extest.enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
  };
  environment.systemPackages = [ mangohudForCurrentKernel ];
  # https://www.reddit.com/r/NixOS/comments/11d76bb/comment/jaqzwyt
  hardware.graphics = {
    extraPackages = [ mangohudForCurrentKernel ];
    extraPackages32 = [ mangohudForCurrentKernel ];
  };
}
