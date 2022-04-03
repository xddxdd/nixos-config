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
    address = [ "194.32.107.228/24" "2a03:94e0:ffff:194:32:107::228/118" "2a03:94e0:27ca::1/48" ];
    gateway = [ "194.32.107.1" "2a03:94e0:ffff:194:32:107::1"];
    matchConfig.Name = "eth0";
  };

  networking.nameservers = [
    # "172.18.0.253"
    "8.8.8.8"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];
}
