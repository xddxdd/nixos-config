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
    address = ["103.172.81.11/28"];
    gateway = ["103.172.81.1"];
    matchConfig.Name = "eth0";
  };

  systemd.network.networks.dummy0.address = [
    "fdbc:f9dc:67ad::8b:c606:ba01/128"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
