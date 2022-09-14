{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  resetKeyboardBacklight = pkgs.writeShellScriptBin "reset-keyboard-backlight" ''
    for F in /sys/devices/platform/hp-wmi/rgb_zones/*; do
      echo "0f84fa" | sudo tee $F
    done
  '';

  bindfsMountOptions = [
    "force-user=lantian"
    "force-group=wheel"
    "create-for-user=rslsync"
    "create-for-group=rslsync"
    "chown-ignore"
    "chgrp-ignore"
    "xattr-none"
  ];
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    # ./nbfc.nix

    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/prime.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/wg-cf-warp.nix
    ../../nixos/optional-apps/x11vnc.nix
  ];

  environment.etc."intel-undervolt.conf".text = ''
    undervolt 0 'CPU' -40
    undervolt 1 'GPU' -40
    undervolt 2 'CPU Cache' -40
    undervolt 3 'System Agent' 0
    undervolt 4 'Analog I/O' 0
  '';

  environment.systemPackages = [ resetKeyboardBacklight ];

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
    spec = "/nix";
    hashTableSizeMB = 128;
    verbosity = "crit";
  };

  services.beesd.filesystems.usb = {
    spec = "/mnt/usb";
    hashTableSizeMB = 2048;
    verbosity = "crit";
  };
  systemd.services."beesd@usb".wantedBy = lib.mkForce [ ];

  services.tlp.settings = {
    # Use powersave scheduler for intel_pstate
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
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
    "/home/lantian/Backups" = {
      device = "/nix/persistent/media/Backups";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Calibre Library" = {
      device = "/nix/persistent/media/Calibre Library";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Music/CloudMusic" = {
      device = "/nix/persistent/media/CloudMusic";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Documents" = {
      device = "/nix/persistent/media/Documents";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/LegacyOS" = {
      device = "/nix/persistent/media/LegacyOS";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Pictures" = {
      device = "/nix/persistent/media/Pictures";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Secrets" = {
      device = "/nix/persistent/media/Secrets";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };

    "/home/lantian/Software" = {
      device = "/mnt/root/files/Software";
      options = [ "bind" ];
    };
    "/home/lantian/.local/share/yuzu" = {
      device = "/mnt/root/files/Yuzu";
      options = [ "bind" ];
    };
  };
}
