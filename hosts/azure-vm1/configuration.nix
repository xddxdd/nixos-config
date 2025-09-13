{ LT, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = LT.cloudLanNetworking "eth0";

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
