{ ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "10.0.0.2/24" ];
    gateway = [ "10.0.0.1" ];
    matchConfig.Name = "eth0";
  };

}
