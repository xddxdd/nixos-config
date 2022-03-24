# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../nixos/hardware/qemu.nix
  ];

  boot.kernelModules = [ "nvme" ];

  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  fileSystems."/nix" = {
    device = "/dev/vda3";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/vda2"; }];
}
