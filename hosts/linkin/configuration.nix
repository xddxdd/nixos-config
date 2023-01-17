{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix

    ../../nixos/optional-apps/auto-mihoyo-bbs
    ../../nixos/optional-apps/yggdrasil-alfis.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "103.172.81.11/28" ];
    gateway = [ "103.172.81.1" ];
    matchConfig.Name = "eth0";
    networkConfig.Tunnel = "henet";
  };

  systemd.network.networks.dummy0.address = [
    "fdbc:f9dc:67ad::8b:c606:ba01/128"
  ];

  systemd.network.netdevs.henet = {
    netdevConfig = {
      Kind = "sit";
      Name = "henet";
    };
    tunnelConfig = {
      Local = LT.this.public.IPv4;
      Remote = "216.218.221.6";
      TTL = 255;
    };
  };

  systemd.network.networks.henet = {
    address = [
      "2001:470:18:10bd::2/64"
      "2001:470:19:10bd::1/64"
      "2001:470:fa1d::1/48"
    ];
    gateway = [ "2001:470:18:10bd::1" ];
    matchConfig.Name = "henet";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:19:10bd::1/120"
      "2001:470:fa1d::1/120"
    ];
  };

  services.yggdrasil.regions = [ "india" "japan" "south-korea" ];
}
