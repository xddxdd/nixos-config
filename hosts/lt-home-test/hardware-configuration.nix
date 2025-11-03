{ ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/hardware/nvidia/cuda-only.nix
    ../../nixos/hardware/nvidia/grid-extension.nix
    ../../nixos/hardware/qemu.nix
    ../../nixos/hardware/qemu-hotplug.nix
  ];

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
    options = [
      "compress-force=zstd"
      "autodefrag"
      "nosuid"
      "nodev"
    ];
  };

  services.qemuGuest.enable = true;
}
