{
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth1 = {
    address = [ "23.94.65.218/30" ];
    gateway = [ "23.94.65.217" ];
    matchConfig.Name = "eth1";
  };

  networking.henet = {
    enable = true;
    remote = "209.51.161.14";
    addresses = [
      "2001:470:1f06:6fe::2/64"
      "2001:470:1f07:6fe::1/64"
      "2001:470:8c19::1/48"
    ];
    gateway = "2001:470:1f06:6fe::1";
    attachToInterface = "eth1";
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
