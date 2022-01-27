{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  imports = [
    ./hardware-configuration.nix

    ../../common/apps/acme-sh.nix
    ../../common/apps/ansible.nix
    ../../common/apps/babeld.nix
    ../../common/apps/bird.nix
    ../../common/apps/coredns.nix
    ../../common/apps/ltnet.nix
    ../../common/apps/nginx-lab.nix
    ../../common/apps/nginx-proxy.nix
    ../../common/apps/nginx.nix
    ../../common/apps/powerdns-recursor.nix
    ../../common/apps/shell.nix
    ../../common/apps/tinc.nix
    ../../common/apps/v2ray.nix
    ../../common/apps/yggdrasil.nix

    ../../common/apps/bird-lg-go.nix
    ../../common/apps/epicgames-claimer.nix
    ../../common/apps/genshin-helper.nix
    ../../common/apps/gitea.nix
    ../../common/apps/grafana.nix
    ../../common/apps/keycloak.nix
    ../../common/apps/nextcloud.nix
    ../../common/apps/quassel.nix
    ../../common/apps/resilio.nix
    ../../common/apps/vaultwarden.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "107.172.197.108/24" ];
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
      MTUBytes = "1480";
    };
    tunnelConfig = {
      Local = thisHost.public.IPv4;
      Remote = "209.51.161.14";
      TTL = 255;
    };
  };

  systemd.network.networks.henet = {
    address = [
      "2001:470:1f06:c6f::2/64"
      "2001:470:1f07:c6f::1/64"
      "2001:470:8d00::1/48"
    ];
    gateway = [ "2001:470:1f06:c6f::1" ];
    matchConfig.Name = "henet";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:1f07:c6f::1/120"
      "2001:470:8d00::1/120"
    ];
  };

  lantian.enable-php = true;

  services.yggdrasil.config.Peers =
    let
      publicPeers = import ../../common/helpers/yggdrasil/public-peers.nix { inherit pkgs; };
    in
    publicPeers [ "united-states" "canada" ];
}
