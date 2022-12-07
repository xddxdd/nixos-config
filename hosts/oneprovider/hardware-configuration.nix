# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    ../../nixos/hardware/general.nix
    ../../nixos/hardware/lvm.nix
  ];

  boot.loader.grub.devices = [
    "/dev/sda"
    "/dev/sdb"
  ];

  fileSystems."/nix" = {
    device = "/dev/mapper/MyVolGroup-root";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/mapper/MyVolGroup-storage";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0E72-608D";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [{ device = "/dev/disk/by-partuuid/0d5cd03d-01"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
