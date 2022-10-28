{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    iperf
    iperf3
    lm_sensors
    nix-top
    nix-tree
    nmap
  ];
}
