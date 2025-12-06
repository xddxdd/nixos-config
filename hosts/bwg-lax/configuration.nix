{ inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    (inputs.secrets + "/dn42/bwg-lax.nix")

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "64.64.231.82/22" ];
    gateway = [ "64.64.228.1" ];
    matchConfig.Name = "eth0";
  };

  # DN42 legacy address
  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::dd:c85a:8a93/128" ];

  networking.henet = {
    enable = true;
    remote = "72.52.104.74";
    addresses = [
      "2001:470:1f04:159::2/64"
      "2001:470:1f05:159::1/64"
      "2001:470:805e::1/48"
    ];
    gateway = "2001:470:1f04:159::1";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:1f05:159::1/120"
      "2001:470:805e::1/120"
    ];
  };
}
