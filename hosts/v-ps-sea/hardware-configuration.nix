# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
_: {
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  fileSystems."/nix" = {
    device = "/dev/vda3";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/vda2";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Needed, or kopia backup fails
  swapDevices = [
    {
      device = "/dev/vda4";
      randomEncryption.enable = true;
    }
  ];
}
