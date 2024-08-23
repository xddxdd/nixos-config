{ inputs, lib, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  boot.loader.grub.enable = lib.mkForce false;

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/23df8a17-50e6-4262-b95d-ac4ab9bb90e4";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-uuid/2178-694E";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/29e85ee5-8c9f-469b-bdab-827b4ef64ae4";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };
}
