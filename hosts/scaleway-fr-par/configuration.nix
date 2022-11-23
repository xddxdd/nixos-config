{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = {
    address = [ "2001:bc8:47a0:66b::1/64" ];
    gateway = [ "2001:bc8:47a0:66b::" ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.yggdrasil.regions = [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];
}
