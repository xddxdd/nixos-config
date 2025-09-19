{ pkgs, ... }:
{
  # FIXME: package broken
  # environment.systemPackages = [ pkgs.clpeak ];

  hardware.graphics.enable = true;

  # FIXME: package broken
  # hardware.graphics.extraPackages = [ pkgs.nur-xddxdd.pocl ];
}
