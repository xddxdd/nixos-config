{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/libvirt.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/x11vnc.nix
  ];

  boot.loader.grub.extraEntries = ''
    menuentry 'Arch Linux (linux-xanmod-lantian)' {
      savedefault
      search --set=drive1 --fs-uuid B406-5B9F
      linux ($drive1)/vmlinuz-linux-xanmod-lantian root=/dev/mapper/root rw rootflags=subvol=archlinux rd.luks.name=23390759-5d5a-4708-8eeb-f72430c3274c=root rd.luks.options=timeout=0,password-echo=no rootflags=x-systemd.device-timeout=0 audit=0 cgroup_enable=memory net.ifnames=0 swapaccount=1 syscall.x32=y intel_iommu=on iommu=pt nowatchdog pcie_aspm=force loglevel=3
      initrd ($drive1)/intel-ucode.img ($drive1)/initramfs-linux-xanmod-lantian.img
    }
    menuentry 'Arch Linux (linux)' {
      savedefault
      search --set=drive1 --fs-uuid B406-5B9F
      linux ($drive1)/vmlinuz-linux root=/dev/mapper/root rw rootflags=subvol=archlinux rd.luks.name=23390759-5d5a-4708-8eeb-f72430c3274c=root rd.luks.options=timeout=0,password-echo=no rootflags=x-systemd.device-timeout=0 audit=0 cgroup_enable=memory net.ifnames=0 swapaccount=1 syscall.x32=y intel_iommu=on iommu=pt nowatchdog pcie_aspm=force loglevel=3
      initrd ($drive1)/intel-ucode.img ($drive1)/initramfs-linux.img
    }
  '';

  environment.etc."intel-undervolt.conf".text = ''
    undervolt 0 'CPU' -80
    undervolt 1 'GPU' -80
    undervolt 2 'CPU Cache' 0
    undervolt 3 'System Agent' 0
    undervolt 4 'Analog I/O' 0
  '';

  environment.systemPackages = with pkgs; [
    aria
    audacious
    colmena
    discord
    firefox
    gnome.gedit
    google-chrome
    mpv
    vscode
    wpsoffice
    zoom-us
  ];

  fileSystems."/".options = [ "size=64G" ];

  programs.steam.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

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

  services.resilio.directoryRoot = pkgs.lib.mkForce "/";
  systemd.services.resilio.serviceConfig = {
    User = pkgs.lib.mkForce "lantian";
    Group = pkgs.lib.mkForce "wheel";
    PrivateMounts = pkgs.lib.mkForce false;
    ProtectHome = pkgs.lib.mkForce "read-only";
    ReadWritePaths = [
      "/home/lantian"
      "/mnt/root/files"
    ];
  };

  services.xserver.displayManager.sddm.settings.X11.ServerArguments = "-dpi 144";

  services.udev.extraHwdb = ''
    # Calc key
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnHP:pnOMEN*:pvr*
      KEYBOARD_KEY_a1=!calc
  '';

  users.users.lantian.extraGroups = [ "rslsync" ];
}
