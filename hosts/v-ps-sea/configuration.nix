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
      "23.145.48.11/24"
      "2605:3a40:4::142/64"
    ];
    gateway = [
      "23.145.48.1"
      "2605:3a40:4::1"
    ];
    matchConfig.Name = "eth0";
  };

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
