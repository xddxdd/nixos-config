{
  lib,
  LT,
  config,
  ...
}:
{
  boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
    # Set the system time from the hardware clock to work around a
    # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
    # to the *boot time* of the host).
    hwclock -s
  '';

  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  # Upstream qemu-guest-agent module sets RestartSec = 0, below the
  # ensure-service-restart policy (RestartSec >= 3s)
  systemd.services.qemu-guest-agent.serviceConfig = LT.serviceHarden // {
    RestartSec = lib.mkForce "5s";
    Restart = "always";
    # Writes to the virtio serial port
    PrivateDevices = false;
    PrivateUsers = false;
    BindPaths = [ "/dev/virtio-ports" ];
  };

  lantian.harden.qemu-guest-agent = true;

  lantian.hostType = "vm";
}
