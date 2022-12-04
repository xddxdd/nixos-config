{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];

  boot.initrd.kernelModules = [
    "dm-cache"
    "dm-integrity"
    "dm-raid"
    "dm-writecache"
    "raid0"
    "raid1"
    "raid10"
    "raid456"
  ];

  services.lvm.dmeventd.enable = true;

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
