{
  config,
  lib,
  ...
}:
{
  imports = [
    ../../nixos/client-components/tlp.nix
    ../../nixos/pve.nix

    ./hardware-configuration.nix
    ./openvswitch.nix
    ./smfc
    ./vfio.nix
  ];

  boot.kernelParams = [
    "console=ttyS0,115200"
    "default_hugepagesz=1G"
    "hugepagesz=1G"
    "hugepages=224"
  ];

  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=1073741824
  '';

  services.tlp.settings = lib.mapAttrs (_n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };

  services.proxmox-ve.bridges = [ "br0" ];

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
