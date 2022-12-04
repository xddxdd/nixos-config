{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../nixos/hardware/general.nix
    ../../nixos/hardware/lvm.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E5D4-ECE6";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/ecba570c-c3e4-47e3-be09-5ee7baec5534";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/mapper/MyVolGroup-storage";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "nosuid" "nodev" ];
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/mnt/storage" ];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
