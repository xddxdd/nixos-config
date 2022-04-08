{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/gui-apps.nix
    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/nvidia-cuda-only.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/wg-cf-warp.nix
    ../../nixos/optional-apps/x11vnc.nix
  ];

  boot.loader.grub.fontSize = 24;
  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-v24n";

  environment.etc."intel-undervolt.conf".text = ''
    undervolt 0 'CPU' -60
    undervolt 1 'GPU' -60
    undervolt 2 'CPU Cache' 0
    undervolt 3 'System Agent' 0
    undervolt 4 'Analog I/O' 0
  '';

  fileSystems."/".options = [ "size=64G" ];

  # This host has full disk encryption, no need to encrypt keyring
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
  security.pam.services.sddm.enableGnomeKeyring = lib.mkForce false;

  services.beesd.filesystems.root = {
    spec = "/nix";
    hashTableSizeMB = 1024;
    verbosity = "crit";
    extraOptions = [ "-c" "2" ];
  };

  services.tlp.settings = {
    # Use powersave scheduler for intel_pstate
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    # On battery GPU is locked to min frequency
    INTEL_GPU_MIN_FREQ_ON_AC = 350;
    INTEL_GPU_MIN_FREQ_ON_BAT = 350;
    INTEL_GPU_MAX_FREQ_ON_AC = 1450;
    INTEL_GPU_MAX_FREQ_ON_BAT = 350;
    INTEL_GPU_BOOST_FREQ_ON_AC = 1450;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 350;
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];

  services.resilio.directoryRoot = lib.mkForce "/";
  systemd.tmpfiles.rules = [
    "A+ /mnt/root/files - - - - u:rslsync:rwx,g:rslsync:rwx,d:u:rslsync:rwx,d:g:rslsync:rwx"
  ];
  systemd.services.resilio.serviceConfig = {
    PrivateMounts = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    ReadWritePaths = [
      "/home/lantian"
      "/mnt/root/files"
    ];
  };

  services.xserver.displayManager.sddm.settings.X11.ServerArguments = "-dpi 144";
  services.xserver.libinput.touchpad = {
    accelSpeed = "0.4";
    clickMethod = "clickfinger";
    disableWhileTyping = false;
  };

  services.udev.extraHwdb = ''
    # Calc key
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnHP:pnOMEN*:pvr*
      KEYBOARD_KEY_a1=!calc
  '';

  users.users.lantian.extraGroups = [ "rslsync" ];
}
