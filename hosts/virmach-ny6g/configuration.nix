{ ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/syncthing
  ];

  systemd.network.networks.eth0 = {
    address = [ "45.42.214.124/24" ];
    gateway = [ "45.42.214.1" ];
    matchConfig.Name = "eth0";
  };
}
