# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
_: {

  boot.initrd.kernelModules = [ "nvme" ];

  boot.loader.grub.mirroredBoots = [
    {
      devices = [ "/dev/vda" ];
      path = "/nix/boot";
    }
  ];

  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "subvol=@rootfs"
      "nosuid"
      "nodev"
    ];
  };

  fileSystems."/boot" = {
    device = "/nix/boot";
    options = [ "bind" ];
  };

  swapDevices = [ { device = "/dev/vda2"; } ];
}
