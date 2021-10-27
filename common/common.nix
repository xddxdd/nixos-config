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
    ./iptables.nix
    ./ssh-harden.nix
    ./users.nix

    ./components/backup.nix
    ./components/dn42.nix
    ./components/php-switch.nix
    ./components/route-chain.nix
  ];

  nixpkgs.config.allowUnfree = true;

  age.secrets.smtp-pass.file = ../secrets/smtp-pass.age;
  age.secrets.smtp-pass.mode = "0444";

  boot = let
    kernelPackage = pkgs.linuxKernel.packagesFor pkgs.nur.repos.xddxdd.linux-xanmod-lantian;
  in {
    kernelParams = [
      "audit=0"
      "cgroup_enable=memory"
      "net.ifnames=0"
      "nofb"
      "nomodeset"
      "swapaccount=1"
      "syscall.x32=y"
      "vga=normal"
    ];
    kernelPackages = kernelPackage;

    initrd.includeDefaultModules = false;

    loader = {
      grub = {
        enable = true;
        version = 2;
        memtest86.enable = true;
        splashImage = null;

        extraFiles = pkgs.lib.mkIf pkgs.stdenv.isx86_64 {
          "netboot.xyz.lkrn" = ./files/netboot.xyz.lkrn;
        };
        extraEntries = pkgs.lib.optionalString pkgs.stdenv.isx86_64 ''
          menuentry "Netboot.xyz" {
            linux16 @bootRoot@/netboot.xyz.lkrn;
          }
        '';
      };
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
    nat.enable = false;
    resolvconf.dnsExtensionMechanism = true;
    resolvconf.dnsSingleRequest = true;
    search = [ "lantian.pub" ];
    tempAddresses = "disabled";
  };

  systemd.network.enable = true;
  environment.etc."systemd/networkd.conf".text = ''
    [Network]
    ManageForeignRoutes=false
  '';
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];
  services.resolved.enable = false;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables = {
    SYSTEMD_PAGER = "";
  };

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
    dig
    git
    htop
    inetutils
    iptables
    nftables
    openssl
    python3Minimal
    screen
    tcpdump
    wget
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
    msmtp = {
      enable = true;
      accounts.default = {
        auth = true;
        host = "smtp.sendgrid.net";
        port = 465;
        from = "postmaster@lantian.pub";
        user = "apikey";
        # A copy of password is in vaultwarden-env.age
        passwordeval = "cat ${config.age.secrets.smtp-pass.path}";
        tls = true;
        tls_starttls = false;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      };
    };
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

  services.journald.extraConfig = ''
    SystemMaxUse=50M
    SystemMaxFileSize=10M
  '';

  virtualisation.podman = {
    enable = true;
    # Podman DNS conflicts with my authoritative resolver
    defaultNetwork.dnsname.enable = false;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  virtualisation.oci-containers.backend = "podman";

  zramSwap.enable = true;
}
