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
    ./impermanence.nix
    ./iptables.nix
    ./ssh-harden.nix
    ./users.nix

    ./components/backup.nix
    ./components/dn42.nix
    ./components/ftp-proxy.nix
    ./components/route-chain.nix
    ./components/web-switch.nix
  ];

  nixpkgs.config.allowUnfree = true;

  age.secrets.smtp-pass = {
    file = ../secrets/smtp-pass.age;
    mode = "0444";
  };

  age.secrets.journalbeat-yml = {
    file = ../secrets/journalbeat-yml.age;
    name = "journalbeat.yml";
  };

  boot = {
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
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      includeDefaultModules = false;
    };

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

    kernel.sysctl = {
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";

      # https://wiki.archlinux.org/title/Security#Kernel_hardening
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 1;
      "net.core.bpf_jit_harden" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.kexec_load_disabled" = 1;

      # https://wiki.archlinux.org/title/sysctl
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 10;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_keepalive_time" = 60;
      "net.ipv4.tcp_keepalive_intvl" = 10;
      "net.ipv4.tcp_keepalive_probes" = 6;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = pkgs.lib.mkForce 0;
      "net.ipv4.conf.default.rp_filter" = pkgs.lib.mkForce 0;
      "net.ipv4.conf.*.rp_filter" = pkgs.lib.mkForce 0;
      "net.ipv4.conf.all.accept_redirects" = pkgs.lib.mkForce 0;
      "net.ipv4.conf.default.accept_redirects" = pkgs.lib.mkForce 0;
      "net.ipv4.conf.*.accept_redirects" = pkgs.lib.mkForce 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.*.secure_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.*.send_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = pkgs.lib.mkForce 0;
      "net.ipv6.conf.default.accept_redirects" = pkgs.lib.mkForce 0;
      "net.ipv6.conf.*.accept_redirects" = pkgs.lib.mkForce 0;
    };
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
    "system/boot/luksroot.nix"
    "tasks/encrypted-devices.nix"
    "tasks/lvm.nix"
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

    # Use NixOS networking scripts for DNS
    # useNetworkd = true;
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

  # Disable systemd-nspawn container's default addresses.
  environment.etc."systemd/network/80-container-ve.network".text = ''
    [Match]
    Name=ve-*
    Driver=veth

    [Network]
    LinkLocalAddressing=ipv6
    DHCPServer=no
    IPMasquerade=both
    LLDP=no
    IPv6SendRA=no
  '';

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
  services.avahi = {
    enable = true;
    nssmdns = true;
    interfaces = [ "ltmesh" ];
    publish = {
      enable = true;
      addresses = true;
      hinfo = true;
      workstation = true;
    };
  };

  services.btrfs.autoScrub = pkgs.lib.mkIf (config.fileSystems."/nix".fsType == "btrfs") {
    enable = true;
    fileSystems = [ "/nix" ];
  };

  services.haveged.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=50M
    SystemMaxFileSize=10M
  '';

  systemd.services.journalbeat =
    let
      stateDir = "journalbeat";
    in
    {
      description = "Journalbeat log shipper";
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p /var/lib/${stateDir}/data
        mkdir -p /var/lib/${stateDir}/logs
      '';
      serviceConfig = {
        StateDirectory = stateDir;
        ExecStart = ''
          ${pkgs.journalbeat7}/bin/journalbeat \
            -c ${config.age.secrets.journalbeat-yml.path} \
            -path.data /var/lib/${stateDir}/data \
            -path.logs /var/lib/${stateDir}/logs'';
        Restart = "always";
      };
    };

  virtualisation.podman = {
    enable = true;
    # Podman DNS conflicts with my authoritative resolver
    defaultNetwork.dnsname.enable = false;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  virtualisation.oci-containers.backend = "podman";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
