{
  lib,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "2a14:67c0:306:211::a/128" ];
    routes = [
      {
        # Special config since gateway isn't in subnet
        Gateway = "2a14:67c0:306::1";
        GatewayOnLink = true;
      }
    ];
    matchConfig.Name = "eth0";
  };

  services.ndppd = {
    enable = true;
    proxies.eth0.rules."2a14:67c0:306:211::/64".method = "static";
  };
  systemd.services.ndppd.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
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
