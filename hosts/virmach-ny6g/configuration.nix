{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  imports = [
    ./hardware-configuration.nix

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
    ../../common/apps/zsh.nix

    ../../common/apps/bird-lg-go.nix
    ../../common/apps/epicgames-claimer.nix
    ../../common/apps/genshin-helper.nix
    ../../common/apps/keycloak.nix
    ../../common/apps/quassel.nix
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
