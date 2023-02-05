{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix

    ../../nixos/optional-apps/auto-mihoyo-bbs
  ];

  systemd.network.networks.eth0 = {
    address = [ "95.214.164.82/24" "2403:2c80:b::12cc/48" ];
    gateway = [ "95.214.164.1" "2403:2c80:b::1" ];
    matchConfig.Name = "eth0";
  };

  systemd.network.networks.dummy0.address = [
    "fdbc:f9dc:67ad::8b:c606:ba01/128"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.yggdrasil.regions = [ "india" "japan" "south-korea" ];
}
