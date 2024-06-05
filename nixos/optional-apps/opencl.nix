{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.clpeak ];

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [ pkgs.pocl ];
}
