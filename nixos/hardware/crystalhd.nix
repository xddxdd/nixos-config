{ config, pkgs, ... }:
{
  boot = {
    kernelModules = [ "crystalhd" ];
    extraModulePackages = [ config.boot.kernelPackages.crystalhd ];
  };
  hardware.firmware = [ pkgs.nur-xddxdd.libcrystalhd.firmware ];
  environment.systemPackages = [ pkgs.nur-xddxdd.gst-plugin-crystalhd ];
}
