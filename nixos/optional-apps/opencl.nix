{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.clpeak ];

  hardware.graphics.enable = true;

  hardware.graphics.extraPackages = [ pkgs.pocl ];
}
