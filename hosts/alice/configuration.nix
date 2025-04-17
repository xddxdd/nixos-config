{ lib, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "2a14:67c0:104::56/128" ];
    routes = [
      {
        # Special config since gateway isn't in subnet
        routeConfig = {
          Gateway = "2a14:67c0:104::1";
          GatewayOnLink = true;
        };
      }
    ];
    matchConfig.Name = "eth0";
  };

  # Cannot connect to log server since this server is IPv6 only
  services.filebeat.enable = lib.mkForce false;

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
