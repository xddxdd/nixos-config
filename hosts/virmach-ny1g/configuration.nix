{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  imports = [
    ./dn42.nix
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
    ../../common/apps/qemu-user-static.nix
    ../../common/apps/tinc.nix
    ../../common/apps/v2ray.nix
    ../../common/apps/yggdrasil.nix
    ../../common/apps/zsh.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "107.172.134.89/24" ];
    gateway = [ "107.172.134.1" ];
    matchConfig.Name = "eth0";
    networkConfig.Tunnel = "henet";
  };

  networking.nameservers = [
    "172.18.0.253"
    "8.8.8.8"
  ];

  systemd.network.netdevs.henet = {
    netdevConfig = {
      Kind = "sit";
      Name = "henet";
    };
    tunnelConfig = {
      Local = thisHost.public.IPv4;
      Remote = "209.51.161.14";
      TTL = 255;
    };
  };

  systemd.network.networks.henet = {
    address = [
      "2001:470:1f06:54d::2/64"
      "2001:470:1f07:54d::1/64"
      "2001:470:8a6d::1/48"
    ];
    gateway = [ "2001:470:1f06:54d::1" ];
    matchConfig.Name = "henet";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:1f07:54d::1/120"
      "2001:470:8a6d::1/120"
    ];
  };

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "united-states" "canada" ];
}
