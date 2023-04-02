# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ../../nixos/hardware/sgx.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-intel"];

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/0faabb3f-212a-4060-bf8d-33cdc9462b57";
    fsType = "btrfs";
    options = ["subvol=nix" "compress-force=zstd" "nosuid" "nodev"];
  };

  fileSystems."/mnt/root" = {
    device = "/dev/disk/by-uuid/0faabb3f-212a-4060-bf8d-33cdc9462b57";
    fsType = "btrfs";
    options = ["compress-force=zstd" "nosuid" "nodev"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5667-EE72";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [{device = "/nix/swapfile";}];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}
