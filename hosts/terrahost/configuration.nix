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

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];
}
