{ pkgs, lib, config, utils, inputs, ... }@args:

{
  home.packages = with pkgs; [
    ethtool
    iperf
    iperf3
    lm_sensors
    nix-top
    nix-tree
    nmap
  ];
}
