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
    device = "/dev/disk/by-uuid/90FC-B221";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/99a228cb-90a7-4bdd-b837-4d33f6866aae";
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
