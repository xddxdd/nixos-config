{ lib, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  # CrowdSec is too IO heavy for this machine
  services.crowdsec.enable = lib.mkForce false;
  services.crowdsec-firewall-bouncer.enable = lib.mkForce false;

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

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
