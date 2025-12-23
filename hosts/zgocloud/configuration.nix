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
}
