{ ... }:
{
  imports = [
    ../../nixos/server.nix

    ./dn42.nix
    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "80.66.196.80/24"
      "2604:a840:2::ed/48"
    ];
    gateway = [
      "80.66.196.1"
      "2604:a840:2::1"
    ];
    matchConfig.Name = "eth0";
  };

  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::dd:c85a:8a93/128" ];

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
