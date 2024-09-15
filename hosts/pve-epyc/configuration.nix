{ config, lib, ... }:
{
  imports = [
    ../../nixos/pve.nix

    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/nvidia/vgpu-extension.nix

    ./hardware-configuration.nix
    ./openvswitch.nix
    ./vfio.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  environment.etc."network/interfaces" = {
    mode = "0644";
    text = ''
      auto br0
      iface br0 inet static
        bridge_ports none
    '';
  };

  networking.hosts = {
    "192.168.0.2" = [ config.networking.hostName ];
  };

  systemd.network.networks.br0 = {
    address = [ "192.168.0.2/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "br0";
    linkConfig.MTUBytes = "9000";
  };

  zramSwap.enable = lib.mkForce false;
}
