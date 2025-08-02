{ config, ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/hardware/nvidia/cuda-only.nix
    ../../nixos/hardware/qemu-hotplug.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E5D4-ECE6";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/ecba570c-c3e4-47e3-be09-5ee7baec5534";
    fsType = "btrfs";
    options = [
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  fileSystems."/".options = [ "size=90%" ];

  services.qemuGuest.enable = true;

  systemd.services.nvidia-power-limit = {
    description = "Set Power Limit for NVIDIA GPUs";
    wantedBy = [ "multi-user.target" ];
    path = [ config.hardware.nvidia.package ];
    script = ''
      nvidia-smi -pl 125
    '';
    serviceConfig.Type = "oneshot";
  };
}
