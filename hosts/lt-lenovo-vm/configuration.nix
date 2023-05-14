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
    address = ["192.168.0.10/24"];
    gateway = ["192.168.0.2"];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
