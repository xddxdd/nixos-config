{
  lib,
  pkgs,
  ...
}:
{
  # https://lowendspirit.com/discussion/11543/shrinking-nixos-ram-footprint-and-resource-requirements-to-the-bare-minimum
  # Avoid a second KSM scanner and THP reservations inside the guest.
  boot.kernelParams = [
    "initcall_blacklist=ksm_init"
    "transparent_hugepage=never"
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    "ras=cec_disable"
    "8250.nr_uarts=1"
  ];
  hardware.ksm.enable = false;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="vd[a-z]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="none", ATTR{queue/read_ahead_kb}="128"
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
