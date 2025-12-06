{
  lib,
  ...
}:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "2a14:67c0:105:10a::a/128" ];
    routes = [
      {
        # Special config since gateway isn't in subnet
        Gateway = "2a14:67c0:105::1";
        GatewayOnLink = true;
      }
    ];
    matchConfig.Name = "eth0";
  };

  services.ndppd = {
    enable = true;
    proxies.eth0.rules."2a14:67c0:105:10a::/64".method = "static";
  };
  systemd.services.ndppd.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  # Server doesn't have enough RAM to complete backup
  systemd.services.backup.enable = lib.mkForce false;

  # Cannot connect to log server since this server is IPv6 only
  services.filebeat.enable = lib.mkForce false;
}
