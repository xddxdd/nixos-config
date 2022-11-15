# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    ../../nixos/hardware/general.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
    gfxmodeBios = "2560x1440x32,auto";
    gfxmodeEfi = "2560x1440x32,auto";
    useOSProber = true;
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.luks.devices."root" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    device = "/dev/disk/by-uuid/23390759-5d5a-4708-8eeb-f72430c3274c";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B406-5B9F";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/nix/persistent/home" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/mnt/c" = {
    device = "/dev/disk/by-uuid/8C60FBA460FB92E6";
    fsType = "ntfs";
    options = [ "rw" "uid=1000" ];
  };

  fileSystems."/mnt/root" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress-force=zstd" "nosuid" "nodev" ];
  };

  fileSystems."/nix/persistent" = {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [ "subvol=persistent" "compress-force=zstd" "nosuid" "nodev" ];
    neededForBoot = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/6a423fb7-a6b9-934c-b587-246c03066e9f";
    discardPolicy = "both";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
    };
  }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}