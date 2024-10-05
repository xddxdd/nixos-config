{ config, lib, ... }:
{
  imports = [
    ../../nixos/pve.nix

    ./hardware-configuration.nix
    ./openvswitch-dpdk.nix
    ./vfio.nix
  ];

  boot.kernelParams = [
    "console=ttyS0,115200"
    "default_hugepagesz=1G"
    "hugepagesz=1G"
    "hugepages=30"
  ];

  services.proxmox-ve.bridges = [ "br0" ];

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
