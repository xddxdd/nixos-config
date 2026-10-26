{
  lib,
  ...
}:
{
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
  systemd.services.qemu-guest-agent.serviceConfig = {
    RestartSec = lib.mkForce "5s";
    Restart = "always";
    # Writes to the virtio serial port
    PrivateDevices = false;
    PrivateUsers = false;
    BindPaths = [ "/dev/virtio-ports" ];
  };

  lantian.harden.qemu-guest-agent.enable = true;

  lantian.hostType = "vm";
}
