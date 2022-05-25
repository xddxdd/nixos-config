{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix
    # ./nbfc.nix

    ../../nixos/optional-apps/gui-apps.nix
    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/nvidia-prime.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/systemd-boot-uefi-secure-boot.nix
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

  lantian.wayland-hidpi = 1.5;

  fileSystems."/".options = [ "size=64G" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

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
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];

  services.resilio.directoryRoot = lib.mkForce "/";
  systemd.tmpfiles.rules = [
    "A+ /mnt/root/files - - - - u:rslsync:rwx,g:rslsync:rwx,d:u:rslsync:rwx,d:g:rslsync:rwx"
  ];
  systemd.services.resilio.serviceConfig = {
    User = lib.mkForce "lantian";
    Group = lib.mkForce "wheel";
    PrivateMounts = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    ReadWritePaths = [
      "/home/lantian"
      "/mnt/root/files"
    ];
  };
  users.users.rslsync.createHome = lib.mkForce false;

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
