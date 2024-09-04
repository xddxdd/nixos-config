{ config, lib, ... }:
{
  imports = [
    ../../nixos/pve.nix

    ./hardware-configuration.nix
    ./openvswitch-dpdk.nix
    ./vfio.nix
  ];

  networking.hosts = {
    "192.168.0.5" = [ config.networking.hostName ];
  };

  systemd.network.networks.br0 = {
    address = [ "192.168.0.5/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "br0";
    linkConfig.MTUBytes = "9000";
  };

  zramSwap.enable = lib.mkForce false;
}
