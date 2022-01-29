{ config, pkgs, ... }:

{
  imports = [
    ./dn42.nix
    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "185.186.147.110/23" "2607:fcd0:100:b100::198a:b7f6/64" ];
    gateway = [ "185.186.146.1" "2607:fcd0:100:b100::1"];
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

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "united-states" "canada" ];
}
