{
  lib,
  LT,
  pkgs,
  ...
}:
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    ./wireplumber-disable-hdmi-audio.nix
    ./xvcd.nix

    ../../nixos/optional-apps/pipewire-combined-sink-alsa.nix
    # ../../nixos/optional-apps/pipewire-network-audio-receive.nix
    ../../nixos/optional-apps/pipewire-roc-source.nix
    ../../nixos/optional-apps/pipewire-vban-recv.nix
    ../../nixos/optional-apps/syncthing.nix
  ];

  lantian.hidpi = 1.5;

  # Edifier speaker has 0.1s latency, so adjust other devices to compensate for that
  lantian.pipewire.latencyAdjust = {
    "alsa_output.pci-0000_00_0e.0.analog-stereo" = 0.1;
    "alsa_output.usb-GeneralPlus_USB_Audio_Device-00.pro-output-0" = 0.1;
    "alsa_output.usb-EDIFIER_USB_Composite_Device_EDI00000X07-00.pro-output-0" = 0;
  };

  # For updating Intel GPU firmware
  environment.systemPackages = [ pkgs.nur-xddxdd.igsc ];

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (_n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };

  # Bind mounts
  fileSystems = {
    "/home/lantian/Music/CloudMusic" = lib.mkForce {
      device = "/nix/persistent/media/CloudMusic";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
  };

  # Auto mount NFS share
  fileSystems."/mnt/share" = {
    device = "${LT.hosts."lt-home-vm".ltnet.IPv4}:/storage";
    fsType = "nfs";
    options = [
      "_netdev"
      "noatime"
      "noauto"
      "clientaddr=${LT.this.ltnet.IPv4}"
      "hard"
      "vers=4.2"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
