{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  bindfsMountOptions = [
    "force-user=lantian"
    "force-group=wheel"
    "create-for-user=root"
    "create-for-group=root"
    "chown-ignore"
    "chgrp-ignore"
    "xattr-none"
    "x-gvfs-hide"
  ];

  bindMountOptions = [
    "bind"
    "x-gvfs-hide"
  ];
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    ./hp-keyboard-backlight
    # ./nbfc.nix

    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/samba.nix
  ];

  boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=2147483647" ];

  lantian.hidpi = 1.5;

  fileSystems."/".options = [ "size=64G" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  hardware.xpadneo.enable = true;

  # This host has full disk encryption, no need to encrypt keyring
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
  security.pam.services.sddm.enableGnomeKeyring = lib.mkForce false;

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 128;
    verbosity = "crit";
    extraOptions = [ "--loadavg-target" "8" ];
  };

  services.samba.shares = {
    "lantian" = {
      "path" = "/home/lantian";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "lantian";
      "force group" = "users";
      "valid users" = "lantian";
    };
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];

  services.xserver.displayManager.sddm.settings.X11.ServerArguments = "-dpi 144";
  services.xserver.libinput.touchpad = {
    accelSpeed = "0.4";
    clickMethod = "clickfinger";
    disableWhileTyping = false;
  };

  # Calc key & Remap pause to delete
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnHP:pnOMEN*:pvr*
      KEYBOARD_KEY_a1=!calc
      KEYBOARD_KEY_c5=delete
  '';

  # Bind mounts
  fileSystems = {
    "/home/lantian/Backups" = lib.mkForce {
      device = "/nix/persistent/media/Backups";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Books" = lib.mkForce {
      device = "/nix/persistent/media/Books";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Calibre Library" = lib.mkForce {
      device = "/nix/persistent/media/Calibre Library";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Music/CloudMusic" = lib.mkForce {
      device = "/nix/persistent/media/CloudMusic";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Documents" = lib.mkForce {
      device = "/nix/persistent/media/Documents";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/LegacyOS" = lib.mkForce {
      device = "/nix/persistent/media/LegacyOS";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Pictures" = lib.mkForce {
      device = "/nix/persistent/media/Pictures";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Secrets" = lib.mkForce {
      device = "/nix/persistent/media/Secrets";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };

    "/home/lantian/Software" = lib.mkForce {
      device = "/mnt/root/files/Software";
      options = bindMountOptions;
    };
    "/home/lantian/.local/share/yuzu" = lib.mkForce {
      device = "/mnt/root/files/Yuzu";
      options = bindMountOptions;
    };
  };

  # Auto mount samba share
  age.secrets.samba-credentials.file = inputs.secrets + "/samba-credentials.age";
  fileSystems."/mnt/share" = {
    device = "//192.168.0.2/storage";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "credentials=${config.age.secrets.samba-credentials.path}"
      "uid=${builtins.toString config.users.users.lantian.uid}"
      "gid=${builtins.toString config.users.groups.wheel.gid}"
    ];
  };
}
