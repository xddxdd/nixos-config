{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
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
    options = ["compress-force=zstd" "nosuid" "nodev"];
  };

  swapDevices = [{device = "/dev/disk/by-uuid/3c75369b-7de9-4cff-82f7-5bf3f8ad2492";}];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
