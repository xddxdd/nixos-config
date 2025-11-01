{ ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/hardware/qemu.nix
    ../../nixos/hardware/qemu-hotplug.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/12CE-A600";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1871c7c3-1f2e-40b9-8375-0478178c82f5";
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
