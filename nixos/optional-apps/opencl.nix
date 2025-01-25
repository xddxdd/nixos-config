{ pkgs, ... }:
{
  # FIXME: package broken
  # environment.systemPackages = [ pkgs.clpeak ];

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.nur-xddxdd.pocl ];
}
