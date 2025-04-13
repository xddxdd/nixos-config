{ LT, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "185.186.147.110/23" ];
    gateway = [ "185.186.146.1" ];
    matchConfig.Name = "eth0";
    networkConfig.Tunnel = "henet";
  };

  systemd.network.netdevs.henet = {
    netdevConfig = {
      Kind = "sit";
      Name = "henet";
    };
    tunnelConfig = {
      Local = LT.this.public.IPv4;
      Remote = "64.62.134.130";
      TTL = 255;
    };
  };

  systemd.network.networks.henet = {
    address = [
      "2001:470:66:ee::2/64"
      "2001:470:67:ee::1/64"
      "2001:470:488d::1/48"
    ];
    gateway = [ "2001:470:66:ee::1" ];
    matchConfig.Name = "henet";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:67:ee::1/120"
      "2001:470:488d::1/120"
    ];
  };
}
