{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/bird-lg-go.nix
    ../../nixos/optional-apps/genshin-helper.nix
    ../../nixos/optional-apps/gitea.nix
    ../../nixos/optional-apps/grafana.nix
    ../../nixos/optional-apps/keycloak.nix
    ../../nixos/optional-apps/nextcloud.nix
    ../../nixos/optional-apps/nginx-lab.nix
    ../../nixos/optional-apps/prometheus.nix
    ../../nixos/optional-apps/quassel.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/vaultwarden.nix
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
      Local = LT.this.public.IPv4;
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

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];
}
