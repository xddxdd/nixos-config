{ config, pkgs, ... }:
{
  boot.initrd.network.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.systemd.network.networks.eth0 = config.systemd.network.networks.eth0;
  boot.initrd.availableKernelModules = [
    "nfsv3"
    "nfsv4"
  ];
  boot.initrd.systemd.extraBin = {
    "mount.nfs" = "${pkgs.nfs-utils}/bin/mount.nfs";
  };
}
