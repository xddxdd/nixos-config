{ config, pkgs, ... }:

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
    address = [
      "107.189.12.254/24"
      "2605:6400:30:f22f::1/64"
      "2605:6400:cac6::1/48"
    ];
    gateway = [ "107.189.12.1" ];
    routes = [{
      # Special config since gateway isn't in subnet
      routeConfig = {
        Gateway = "2605:6400:30::1";
        GatewayOnLink = true;
      };
    }];
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
      "2605:6400:30:f22f::1/120"
      "2605:6400:cac6::1/120"
    ];
  };

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];
}
