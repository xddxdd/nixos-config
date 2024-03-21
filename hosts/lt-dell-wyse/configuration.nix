{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    ./wireplumber-disable-hdmi-audio.nix

    ../../nixos/optional-apps/pipewire-network-audio-receive.nix
    ../../nixos/optional-apps/pipewire-rtp-source.nix
    ../../nixos/optional-apps/syncthing.nix
  ];

  lantian.hidpi = 1.5;

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    SOUND_POWER_SAVE_ON_AC = 0;
    SOUND_POWER_SAVE_ON_BAT = 0;
  };

  lantian.pipewire-rtp-source-ifname = "eth0";

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
