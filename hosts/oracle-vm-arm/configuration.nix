{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/yggdrasil-alfis.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = {
    address = [ "172.18.126.4/24" ];
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

  services.yggdrasil.config.Peers = LT.yggdrasil [ "india" "japan" "south-korea" ];
}
