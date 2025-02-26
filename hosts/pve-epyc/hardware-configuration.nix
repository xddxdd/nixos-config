# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, ... }:
{
  imports = [
    ../../nixos/hardware/lvm.nix
    ../../nixos/hardware/ups.nix
    ../../nixos/hardware/zfs.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  boot.zfs.extraPools = [ "nvme-zfs" ];

  networking.usePredictableInterfaceNames = lib.mkForce true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/815E-3292";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/fad6832b-1bde-4bda-90ba-51520e0feef4";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  systemd.services.nvidia-power-limit = {
    # P40 removed, no longer needed
    enable = false;
    description = "Set Power Limit for NVIDIA GPUs";
    wantedBy = [ "multi-user.target" ];
    path = [ config.hardware.nvidia.package ];
    script = ''
      nvidia-smi -pl 125
    '';
  };
}
