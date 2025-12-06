{
  lib,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ../../nixos/optional-apps/ndppd.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "5.102.125.26/24"
      "2a14:67c0:306:211::a/128"
    ];
    gateway = [ "5.102.125.1" ];
    routes = [
      {
        # Special config since gateway isn't in subnet
        Gateway = "2a14:67c0:306::1";
        GatewayOnLink = true;
      }
    ];
    matchConfig.Name = "eth0";
  };

  services.ndppd.proxies.eth0.rules."2a14:67c0:306:211::/64".method = "static";

  # Cannot connect to log server since this server is IPv6 only
  services.filebeat.enable = lib.mkForce false;

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
