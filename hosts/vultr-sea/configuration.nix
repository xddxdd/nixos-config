{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/asterisk
  ];

  systemd.network.networks.eth0 = {
    address = [
      "144.202.83.81/24"
      "2001:19f0:8001:5b2:5400:04ff:fe57:2a89/64"
    ];
    gateway = [
      "144.202.83.1"
      "_ipv6ra"
    ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
