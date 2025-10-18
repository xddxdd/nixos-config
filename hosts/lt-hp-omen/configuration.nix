{
  lib,
  LT,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../nixos/client.nix

    ./backup.nix
    ./hardware-configuration.nix
    ./hp-keyboard-backlight
    ./nandsim.nix
    # ./nbfc.nix

    ../../nixos/optional-apps/byparr.nix
    # ../../nixos/optional-apps/clamav.nix
    ../../nixos/optional-apps/dae.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/mcp-roo-code.nix
    ../../nixos/optional-apps/netns-tnl-buyvm.nix
    ../../nixos/optional-apps/nix-distributed.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/ollama.nix
    ../../nixos/optional-apps/opencl.nix
    ../../nixos/optional-apps/pipewire-roc-sink.nix
    ../../nixos/optional-apps/qdrant.nix
    ../../nixos/optional-apps/samba.nix
    ../../nixos/optional-apps/syncthing.nix
    ../../nixos/optional-apps/virtualbox.nix
    ../../nixos/optional-apps/vlmcsd.nix

    "${inputs.secrets}/nixos-hidden-module/7e653824810bb88d"
  ];

  boot.kernelParams = [ "cfg80211.ieee80211_regdom=US" ];

  lantian.hidpi = 1.5;

  environment.systemPackages = [
    pkgs.nur-xddxdd.unigine-heaven
    pkgs.nur-xddxdd.unigine-sanctuary
    pkgs.nur-xddxdd.unigine-superposition
    pkgs.nur-xddxdd.unigine-tropics
    pkgs.nur-xddxdd.unigine-valley
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  hardware.xpadneo.enable = true;

  lantian.pipewire.roc-sink-ip = [
    "192.168.0.207"
  ];

  # This host has full disk encryption, no need to encrypt keyring
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
  security.pam.services.sddm.enableGnomeKeyring = lib.mkForce false;

  services.samba.settings = {
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
      "veto files" = "/._*/.DS_Store/Thumbs.db/";
      "delete veto files" = "yes";
    };
  };

  services.displayManager.sddm.settings.X11.ServerArguments = "-dpi 144";
  services.libinput.touchpad = {
    accelSpeed = "0.4";
    clickMethod = "clickfinger";
    disableWhileTyping = false;
  };

  services.usbmuxd.enable = true;
  systemd.services.usbmuxd.serviceConfig.Restart = "always";

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
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Books" = lib.mkForce {
      device = "/nix/persistent/media/Books";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Calibre Library" = lib.mkForce {
      device = "/nix/persistent/media/Calibre Library";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Music/CloudMusic" = lib.mkForce {
      device = "/nix/persistent/media/CloudMusic";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Documents" = lib.mkForce {
      device = "/nix/persistent/media/Documents";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/LegacyOS" = lib.mkForce {
      device = "/nix/persistent/media/LegacyOS";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Pictures" = lib.mkForce {
      device = "/nix/persistent/media/Pictures";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Secrets" = lib.mkForce {
      device = "/nix/persistent/media/Secrets";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/Software" = lib.mkForce {
      device = "/nix/persistent/media/Software";
      fsType = "fuse.bindfs";
      options = LT.constants.bindfsMountOptions;
    };
    "/home/lantian/.local/share/yuzu" = lib.mkForce {
      device = "/nix/persistent/media/Yuzu";
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

  services.yggdrasil.regions = [ "united-states" ];
}
