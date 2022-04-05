{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "103.172.81.11/28" ];
    gateway = [ "103.172.81.1" ];
    matchConfig.Name = "eth0";
  };

  networking.nameservers = [
    "172.18.0.253"
    "8.8.8.8"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "india" "japan" "south-korea" ];
}
