{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  bindfsMountOptions = [
    "force-user=lantian"
    "force-group=lantian"
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
in {
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    ./hp-keyboard-backlight
    ./nandsim.nix
    # ./nbfc.nix

    ../../nixos/optional-apps/homer.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/samba.nix
    ../../nixos/optional-apps/vlmcsd.nix

    # Disabled since remote nix builds in /tmp
    # ../../nixos/optional-apps/nix-distributed.nix
  ];

  boot.kernelParams = [
    "cfg80211.ieee80211_regdom=US"
  ];

  lantian.hidpi = 1.5;

  fileSystems."/".options = ["size=64G"];

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
    extraOptions = ["--loadavg-target" "8"];
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
      "force group" = "lantian";
      "valid users" = "lantian";
    };
  };

  services.xserver.displayManager.sddm.settings.X11.ServerArguments = "-dpi 144";
  services.xserver.libinput.touchpad = {
    accelSpeed = "0.4";
    clickMethod = "clickfinger";
    disableWhileTyping = false;
  };

  virtualisation.waydroid.enable = true;

  # Calc key & Remap pause to delete
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnHP:pnOMEN*:pvr*
      KEYBOARD_KEY_a1=!calc
      KEYBOARD_KEY_c5=delete
      KEYBOARD_KEY_4f=f13
      KEYBOARD_KEY_50=f14
      KEYBOARD_KEY_51=f15
      KEYBOARD_KEY_4b=mail
      KEYBOARD_KEY_4c=bookmarks
      KEYBOARD_KEY_4d=computer
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
