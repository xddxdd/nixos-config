{
  lib,
  LT,
  ...
}:
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    ./hp-keyboard-backlight.nix

    ../../nixos/optional-apps/clamav.nix
    ../../nixos/optional-apps/kubo.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/llama-cpp.nix
    ../../nixos/optional-apps/llama-swap.nix
    ../../nixos/optional-apps/ncps-client.nix
    ../../nixos/optional-apps/netns-tnl-buyvm.nix
    ../../nixos/optional-apps/nix-distributed.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/opencl.nix
    ../../nixos/optional-apps/pi-web.nix
    ../../nixos/optional-apps/pipewire-roc-sink.nix
    ../../nixos/optional-apps/syncthing
    ../../nixos/optional-apps/virtualbox.nix
    ../../nixos/optional-apps/whisper-cpp.nix
  ];

  boot.kernelParams = [ "cfg80211.ieee80211_regdom=US" ];

  # Try fix qtwebengine issue
  hardware.nvidia.open = lib.mkForce false;

  lantian.backup = {
    enable = true;
    resticRepos = [ "home" ];
    schedule = "daily";
    persistentTimer = true;
  };

  lantian.hidpi = 1.5;

  # Firewalled host, so the public firewall preset is off by default.
  lantian.firewall.presets.public-firewall.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  hardware.xpadneo.enable = true;

  lantian.pipewire.roc-sink-ip = [
    "192.168.0.207"
  ];

  # ClamAV daemon doesn't have permission to user home folder
  services.clamav.daemon.enable = lib.mkForce false;

  lantian.localVhosts = {
    lab.locations."/".enableOAuth = true;
    llama-swap.locations."/".enableOAuth = true;
    pi.locations."/".enableOAuth = true;
  };

  services.displayManager.sddm.settings.X11.ServerArguments = "-dpi 144";
  services.libinput.touchpad = {
    accelSpeed = "0.4";
    clickMethod = "clickfinger";
    disableWhileTyping = false;
  };

  services.syncthing = {
    user = lib.mkForce "lantian";
    group = lib.mkForce "lantian";
  };
  lantian.syncthing.storage = "/home/lantian";
  systemd.services.syncthing.serviceConfig = {
    ProtectHome = false;
    BindPaths = [ "/home/lantian" ];
  };

  services.usbmuxd.enable = true;
  systemd.services.usbmuxd.serviceConfig.Restart = "always";
  systemd.services.usbmuxd.serviceConfig.RestartSec = "5s";

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

  fileSystems."/mnt/share" = {
    device = "${LT.hosts."pve-epyc".ltnet.IPv4}:/storage";
    fsType = "nfs";
    options = [
      "_netdev"
      "noatime"
      "noauto"
      "clientaddr=${LT.this.ltnet.IPv4}"
      "hard"
      "vers=4.2"
      "nconnect=16"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
