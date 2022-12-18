{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "185.186.147.110/23" "2607:fcd0:100:b100::198a:b7f6/64" ];
    gateway = [ "185.186.146.1" "2607:fcd0:100:b100::1"];
    matchConfig.Name = "eth0";
  };

  systemd.network.networks.dummy0.address = [
    "fdbc:f9dc:67ad::dd:c85a:8a93/128"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
