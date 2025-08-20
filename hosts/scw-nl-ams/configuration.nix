{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}:

{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = "yes";
    };
    ipv6AcceptRAConfig = {
      Token = "::1";
      DHCPv6Client = "no";
    };
    matchConfig.Name = "eth0";
  };

  lantian.ipv4TrafficRouteHost = LT.hosts.hetzner-de;

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:bc8:1640:4f1f::1/120"
    ];
  };

  services.yggdrasil.regions = [
    "germany"
    "france"
    "luxembourg"
    "netherlands"
    "united-kingdom"
  ];
}
