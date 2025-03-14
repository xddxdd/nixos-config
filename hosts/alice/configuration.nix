{ ... }:
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

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
