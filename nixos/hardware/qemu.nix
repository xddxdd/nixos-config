{
  lib,
  pkgs,
  ...
}:
{
  boot.pruneKernelModules = true;
  boot.availableKernelModules = [
    "dmi_sysfs"
    "evdev"
    "joydev"
    "mousedev"
    "qemu_fw_cfg"
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    "button"
    "input_leds"
    "mac_hid"
    "psmouse"
    "rtc_cmos"
    "serio_raw"
    "tiny_power_button"
    "vga16fb"
    "vmgenid"
  ];

  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = [
    "sd_mod"
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    "atkbd"
    "i8042"
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
