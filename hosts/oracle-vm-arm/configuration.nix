{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../common/optional-apps/resilio.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = {
    address = [ "172.18.126.4/24" ];
    gateway = [ "172.18.126.1" ];
    networkConfig.DHCP = "ipv6";
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
    publicPeers [ "japan" ];
}
