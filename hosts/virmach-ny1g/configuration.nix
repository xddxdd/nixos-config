{ inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    (inputs.secrets + "/dn42/virmach-ny1g.nix")

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "45.42.214.121/24" ];
    gateway = [ "45.42.214.1" ];
    matchConfig.Name = "eth0";
  };

  networking.henet = {
    enable = true;
    remote = "209.51.161.14";
    addresses = [
      "2001:470:1f06:54d::2/64"
      "2001:470:1f07:54d::1/64"
      "2001:470:8a6d::1/48"
    ];
    gateway = "2001:470:1f06:54d::1";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:1f07:54d::1/120"
      "2001:470:8a6d::1/120"
    ];
  };
}
