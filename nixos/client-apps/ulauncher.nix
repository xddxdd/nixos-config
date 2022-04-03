{ config, pkgs, lib, ... }:

{
  # Fix ulauncher startup error
  environment.systemPackages = with pkgs; [ ulauncher ];
  environment.pathsToLink = [ "/share/ulauncher" ];
}
