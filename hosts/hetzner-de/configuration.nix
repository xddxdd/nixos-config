{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = ["142.132.236.113/24" "2a01:4f8:c012:6530::1/64"];
    matchConfig.Name = "eth0";
    networkConfig = {
      IPv6AcceptRA = false;
    };
    routes = [
      {
        routeConfig = {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        };
      }
      {
        routeConfig = {
          Gateway = "fe80::1";
          GatewayOnLink = true;
        };
      }
    ];
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
