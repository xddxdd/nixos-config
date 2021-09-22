# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modules, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    binaryCaches = [
      "https://xddxdd.cachix.org"
    ];
    binaryCachePublicKeys = [
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8="
    ];

    autoOptimiseStore = true;
    gc = {
      automatic = true;
      options = "-d";
      randomizedDelaySec = "1h";
    };
    optimise.automatic = true;
    sshServe = {
      enable = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcWoEQ4Mh27AV3ixcn9CMaUK/R+y4y5TqHmn2wJoN6i lantian@lantian-lenovo-archlinux"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCulLscvKjEeroKdPE207W10MbZ3+ZYzWn34EnVeIG0GzfZ3zkjQJVfXFahu97P68Tw++N6zIk7htGic9SouQuAH8+8kzTB8/55Yjwp7W3bmqL7heTmznRmKehtKg6RVgcpvFfciyxQXV/bzOkyO+xKdmEw+fs92JLUFjd/rbUfVnhJKmrfnohdvKBfgA27szHOzLlESeOJf3PuXV7BLge1B+cO8TJMJXv8iG8P5Uu8UCr857HnfDyrJS82K541Scph3j+NXFBcELb2JSZcWeNJRVacIH3RzgLvp5NuWPBCt6KET1CCJZLsrcajyonkA5TqNhzumIYtUimEnAPoH51hoUD1BaL4wh2DRxqCWOoXn0HMrRmwx65nvWae6+C/7l1rFkWLBir4ABQiKoUb/MrNvoXb+Qw/ZRo6hVCL5rvlvFd35UF0/9wNu1nzZRSs9os2WLBMt00A4qgaU2/ux7G6KApb7shz1TXxkN1k+/EKkxPj/sQuXNvO6Bfxww1xEWFywMNZ8nswpSq/4Ml6nniS2OpkZVM2SQV1q/VdLEKYPrObtp2NgneQ4lzHmAa5MGnUCckES+qOrXFZAcpI126nv1uDXqA2aytN6WHGfN50K05MZ+jA8OM9CWFWIcglnT+rr3l+TI/FLAjE13t6fMTYlBH0C8q+RnQDiIncNwyidQ== lantian@LandeMacBook-Pro.local"
      ];
    };
  };

  imports = [
    ./users.nix
    ./apps/zsh.nix
    ./ssh-harden.nix

    ./apps/qemu-user-static.nix

    ./apps/nginx.nix
    ./apps/ansible.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot = let
    kernelPackage = pkgs.linuxKernel.packagesFor pkgs.nur.repos.xddxdd.linux-xanmod-lantian;
  in {
    kernelParams = [
      "vga=normal"
      "nofb"
      "nomodeset"
      "audit=0"
      "cgroup_enable=memory"
      "swapaccount=1"
      "syscall.x32=y"
    ];
    kernelPackages = kernelPackage;
    # extraModulePackages = with config.boot.kernelPackages; [ netatop ];

    initrd.includeDefaultModules = false;

    loader = {
      grub = {
        enable = true;
        version = 2;
        #efiSupport = true;
        #efiInstallAsRemovable = true;
        memtest86.enable = true;
        splashImage = null;
        useOSProber = true;
      };
      efi.canTouchEfiVariables = false;
    };
    # tmpOnTmpfs = true;
  };

  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  disabledModules = [
    "tasks/swraid.nix"
  ];

  networking = {
    usePredictableInterfaceNames = false;
    useDHCP = false;
    domain = "lantian.pub";
    firewall.enable = false;
    firewall.checkReversePath = false;
    iproute2.enable = true;
    nat.enable = true;
    nat.enableIPv6 = true;
    nat.externalInterface = "eth0";
    resolvconf.dnsExtensionMechanism = true;
    resolvconf.dnsSingleRequest = true;
    tempAddresses = "disabled";
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.homeBinInPath = true;
  #environment.memoryAllocator.provider = "jemalloc";

  #environment.etc."ld-nix.so.preload".text = ''
  #  ${pkgs.mimalloc}/lib/libmimalloc.so
  #'';
  #security.apparmor.includes = {
  #  "abstractions/base" = ''
  #    r /etc/ld-nix.so.preload,
  #    r ${config.environment.etc."ld-nix.so.preload".source},
  #    mr ${pkgs.mimalloc}/lib/libmimalloc.so,
  #  '';
  #};

  environment.systemPackages = with pkgs; [
    crun
    git
    screen
    wget
    htop
  ];

  hardware.ksm.enable = true;

  programs = {
    #atop.enable = true;
    #atop.netatop.enable = true;
    bash.vteIntegration = true;
    iftop.enable = true;
    iotop.enable = true;
    less.enable = true;
    mosh.enable = true;
    mtr.enable = true;
    ssh.forwardX11 = true;
    traceroute.enable = true;
  };

  security.dhparams.defaultBitSize = 4096;
  security.protectKernelImage = true;
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;

  # List services that you want to enable:
  services.haveged.enable = true;

  #virtualisation.docker = {
  #  enable = true;
  #  enableOnBoot = true;
  #  autoPrune = {
  #    enable = true;
  #    flags = [ "-a" ];
  #  };
  #  extraOptions = "--userland-proxy=false --experimental=true --ip6tables=true --add-runtime=crun=${pkgs.crun}/bin/crun --default-runtime=crun";
  #};

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  zramSwap.enable = true;
}
