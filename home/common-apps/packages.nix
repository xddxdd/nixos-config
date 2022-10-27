{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    lm_sensors
    nix-top
    nix-tree
    nmap
  ];
}
