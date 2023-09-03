# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "sr_mod" "xen_blkfront"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  boot.loader.grub.device = "/dev/xvda"; # or "nodev" for efi only

  fileSystems."/nix" = {
    device = "/dev/mapper/debian-root";
    fsType = "btrfs";
    options = ["compress-force=zstd" "nosuid" "nodev"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9538ac34-7ace-45b9-9304-f452f28166d1";
    fsType = "ext4";
    options = ["nosuid" "nodev"];
  };

  swapDevices = [{device = "/dev/mapper/debian-swap";}];
}
