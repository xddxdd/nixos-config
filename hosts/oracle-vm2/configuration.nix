{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../common/apps/acme-sh.nix
    ../../common/apps/ansible.nix
    ../../common/apps/babeld.nix
    ../../common/apps/bird.nix
    ../../common/apps/coredns.nix
    ../../common/apps/ltnet.nix
    ../../common/apps/nginx-proxy.nix
    ../../common/apps/nginx.nix
    ../../common/apps/powerdns-recursor.nix
    ../../common/apps/shell.nix
    ../../common/apps/tinc.nix
    ../../common/apps/v2ray.nix
    ../../common/apps/yggdrasil.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = {
    address = [ "172.18.126.3/24" ];
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

  services.openiscsi = {
    enable = true;
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:${config.networking.hostName}";
  };

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "japan" ];
}
