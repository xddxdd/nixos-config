{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "107.189.12.254/24"
      "2605:6400:30:f22f::1/64"
      "2605:6400:cac6::1/48"
    ];
    gateway = [ "107.189.12.1" ];
    routes = [{
      # Special config since gateway isn't in subnet
      routeConfig = {
        Gateway = "2605:6400:30::1";
        GatewayOnLink = true;
      };
    }];
    matchConfig.Name = "eth0";
  };

  networking.nameservers = [
    "172.18.0.253"
    "8.8.8.8"
  ];

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2605:6400:30:f22f::1/120"
      "2605:6400:cac6::1/120"
    ];
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "germany" "france" "luxembourg" "netherlands" "united-kingdom" ];
}
