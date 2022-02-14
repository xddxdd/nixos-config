# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../nixos/hardware/general.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    efiSupport = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot/esp0"; }
      { devices = [ "nodev" ]; path = "/boot/esp1"; }
      { devices = [ "nodev" ]; path = "/boot/esp2"; }
      { devices = [ "nodev" ]; path = "/boot/esp3"; }
    ];
  };
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";

  fileSystems."/nix" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [ "compress-force=zstd" ];
  };

  fileSystems."/boot/esp0" = {
    device = "/dev/disk/by-uuid/1415-5827";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/boot/esp1" = {
    device = "/dev/disk/by-uuid/143C-186E";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/boot/esp2" = {
    device = "/dev/disk/by-uuid/144A-CCED";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/boot/esp3" = {
    device = "/dev/disk/by-uuid/145A-606D";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
