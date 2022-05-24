{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = {
    address = [ "172.18.126.2/24" ];
    gateway = [ "172.18.126.1" ];
    networkConfig.DHCP = "ipv6";
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${config.networking.hostName}";
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "india" "japan" "south-korea" ];
}
