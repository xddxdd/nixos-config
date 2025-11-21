{
  ...
}:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth1 = {
    address = [ "23.94.65.218/30" ];
    gateway = [ "23.94.65.217" ];
    matchConfig.Name = "eth1";
  };
}
