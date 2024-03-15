{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  environment.systemPackages = with pkgs; [
    obs-studio
    obs-studio-plugins.looking-glass-obs
    obs-studio-plugins.obs-gstreamer
    obs-studio-plugins.obs-nvfbc
    obs-studio-plugins.wlrobs
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  # Don't autoload as it conflicts with physical camera on some programs
  # boot.kernelModules = [ "v4l2loopback" ];

  users.users.lantian.extraGroups = [ "video" ];
}
