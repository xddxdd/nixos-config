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
  ];
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    ./hp-keyboard-backlight
    # ./nbfc.nix

    ../../nixos/optional-apps/ksmbd.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/prime.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/wg-cf-warp.nix
  ];

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

  services.ksmbd = {
    enable = true;
    shares = {
      "lantian" = {
        "path" = "/home/lantian";
        "read only" = false;
        "force user" = "lantian";
        "force group" = "users";
        "valid users" = "lantian";
      };
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
      options = [ "bind" ];
    };
    "/home/lantian/.local/share/yuzu" = lib.mkForce {
      device = "/mnt/root/files/Yuzu";
      options = [ "bind" ];
    };
  };
}
