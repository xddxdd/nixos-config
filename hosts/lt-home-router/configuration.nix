{ ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    # FIXME
    address = [ "192.168.0.249/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "eth0";
  };
}
