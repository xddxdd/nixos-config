{ ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/syncthing.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "45.42.214.124/24" ];
    gateway = [ "45.42.214.1" ];
    matchConfig.Name = "eth0";
  };

  networking.henet = {
    enable = true;
    remote = "209.51.161.14";
    addresses = [
      "2001:470:1f06:c6f::2/64"
      "2001:470:1f07:c6f::1/64"
      "2001:470:8d00::1/48"
    ];
    gateway = "2001:470:1f06:c6f::1";
  };

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
      "2001:470:1f07:c6f::1/120"
      "2001:470:8d00::1/120"
    ];
  };
}
