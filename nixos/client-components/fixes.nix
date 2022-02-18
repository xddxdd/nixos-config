{ config, pkgs, ... }:

{
  # Fix ulauncher startup error
  environment.pathsToLink = [ "/share/ulauncher" ];
}
