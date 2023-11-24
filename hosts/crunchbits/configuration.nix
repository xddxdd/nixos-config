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
    address = ["38.175.193.201/22" "2606:a8c0:3:415::a/64"];
    gateway = ["38.175.192.1"];
    routes = [
      {
        # Special config since gateway isn't in subnet
        routeConfig = {
          Gateway = "2606:a8c0:3::1";
          GatewayOnLink = true;
        };
      }
    ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
