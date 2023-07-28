{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ../../nixos/hardware/qemu.nix
  ];

  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E5D4-ECE6";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/ecba570c-c3e4-47e3-be09-5ee7baec5534";
    fsType = "btrfs";
    options = ["compress-force=zstd" "nosuid" "nodev"];
  };

  services.qemuGuest.enable = true;
}
