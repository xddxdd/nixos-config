# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../nixos/hardware/hdr.nix
    ../../nixos/hardware/nvidia/only.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.extraModprobeConfig = ''
    blacklist r8169
    install r8169 ${pkgs.coreutils}/bin/true
  '';

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F5AA-FBC7";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/07d35261-a376-4784-81b3-54362c45cc57";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
