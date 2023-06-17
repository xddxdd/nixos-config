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
  imports = [
    ../../nixos/hardware/lvm.nix
    ../../nixos/hardware/qemu.nix
  ];

  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.loader.grub.mirroredBoots = [
    {
      devices = ["/dev/vda"];
      path = "/nix/boot";
    }
  ];

  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "btrfs";
    options = ["compress-force=zstd" "nosuid" "nodev"];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/mapper/MyVolGroup-storage";
    fsType = "btrfs";
    options = ["compress-force=zstd" "nosuid" "nodev" "nofail"];
  };

  fileSystems."/boot" = {
    device = "/nix/boot";
    options = ["bind"];
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/mnt/storage"];
  };

  services.qemuGuest.enable = true;
}
