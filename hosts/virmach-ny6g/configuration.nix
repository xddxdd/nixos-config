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

  services."route-chain" = {
    enable = true;
    routes = [
      "172.22.76.97/29"
    ];
  };
}
