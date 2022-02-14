{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "107.172.197.23/24" ];
    gateway = [ "107.172.197.1" ];
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
      Local = LT.this.public.IPv4;
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

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];
}
