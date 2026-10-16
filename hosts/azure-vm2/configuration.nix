{ LT, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = LT.cloudLanNetworking "eth0" 1024;
}
