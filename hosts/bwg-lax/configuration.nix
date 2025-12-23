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
    # SIT tunnel provided by BandwagonHost
    enable = true;
    remote = "207.246.106.118";
    addresses = [ "2607:8700:5501:574f::2/64" ];
    gateway = "2607:8700:5501:574f::1";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
