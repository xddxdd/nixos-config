{ config, ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/hardware/nvidia/cuda-only.nix
    ../../nixos/hardware/qemu.nix
    ../../nixos/hardware/qemu-hotplug.nix
  ];

  boot.initrd.kernelModules = [ "virtiofs" ];

  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E5D4-ECE6";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "virtiofs-nixos-home-rdp";
    fsType = "virtiofs";
  };

  fileSystems."/mnt/storage" = {
    device = "192.168.0.2:/mnt/storage";
    fsType = "nfs";
    options = [
      "_netdev"
      "noatime"
      "clientaddr=192.168.1.13"
      "hard"
      "vers=4.2"
    ];
  };

  services.qemuGuest.enable = true;

  systemd.services.nvidia-power-limit = {
    description = "Set Power Limit for NVIDIA GPUs";
    wantedBy = [ "multi-user.target" ];
    path = [ config.hardware.nvidia.package ];
    script = ''
      nvidia-smi --gpu-target-temp 65
      nvidia-smi -pl 250
    '';
    serviceConfig.Type = "oneshot";
  };
}
