{
  lib,
  LT,
  pkgs,
  inputs,
  config,
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

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
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

  # Auto mount samba share
  age.secrets.samba-credentials.file = inputs.secrets + "/samba-credentials.age";
  fileSystems."/mnt/share" = {
    device = "//192.168.1.10/storage";
    fsType = "cifs";
    options = [
      "_netdev"
      "credentials=${config.age.secrets.samba-credentials.path}"
      "gid=${builtins.toString config.users.groups.lantian.gid}"
      "noauto"
      "uid=${builtins.toString config.users.users.lantian.uid}"
      "users"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
