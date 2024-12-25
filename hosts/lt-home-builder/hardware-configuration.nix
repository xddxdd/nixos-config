# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/hardware/qemu-hotplug.nix
  ];

  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  fileSystems."/nix" = {
    device = "/dev/vda2";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  services.qemuGuest.enable = true;

  swapDevices = [
    {
      device = "/dev/vda3";
      randomEncryption.enable = true;
    }
  ];
}
