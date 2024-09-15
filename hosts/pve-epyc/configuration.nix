{ config, lib, ... }:
{
  imports = [
    ../../nixos/pve.nix

    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/nvidia/vgpu-extension.nix

    ./hardware-configuration.nix
    # ./openvswitch-dpdk.nix
    # ./vfio.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  networking.hosts = {
    "192.168.0.2" = [ config.networking.hostName ];
  };

  systemd.network.networks.enp97s0d1 = {
    address = [ "192.168.0.2/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "enp97s0d1";
    linkConfig.MTUBytes = "9000";
  };

  zramSwap.enable = lib.mkForce false;
}
