{ inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    (inputs.secrets + "/dn42/zgocloud.nix")

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "38.175.199.35/24"
      # "2403:2c80:b::12cc/48"
    ];
    gateway = [
      "38.175.199.254"
      # "2403:2c80:b::1"
    ];
    matchConfig.Name = "eth0";
  };

  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::8b:c606:ba01/128" ];

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
