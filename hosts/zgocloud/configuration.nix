{ ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "38.175.199.35/24" ];
    gateway = [ "38.175.199.254" ];
    matchConfig.Name = "eth0";
  };

  networking.henet = {
    enable = true;
    remote = "216.218.221.6";
    addresses = [
      "2001:470:18:c69::2/64"
      "2001:470:19:c66::1/64"
    ];
    gateway = "2001:470:18:c69::1";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:19:c66::1/120"
    ];
  };
}
