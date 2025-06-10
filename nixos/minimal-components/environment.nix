{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.default-pw = {
    file = inputs.secrets + "/default-pw.age";
    mode = "0444";
  };

  boot.enableContainers = config.containers != { };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
  ];

  environment.enableAllTerminfo = true;
  environment.homeBinInPath = true;
  environment.localBinInPath = true;
  environment.variables = {
    DXVK_LOG_PATH = "none";
    DXVK_STATE_CACHE_PATH = "/tmp";
    KOPIA_CHECK_FOR_UPDATES = "false";
    NIX_REMOTE = "daemon";
    NIXPKGS_ALLOW_INSECURE = "1";
    OLLAMA_HOST = "http://ollama.localhost";
    SYSTEMD_PAGER = "";
  };
  environment.defaultPackages = [ ];
  environment.systemPackages =
    with pkgs;
    [
      bat
      bridge-utils
      curlHTTP3
      dig
      duf
      eza
      fuc
      fzf
      gitMinimal
      gzip
      inetutils
      iperf3
      iptables
      iw
      kopia
      lsof
      mbuffer # required for btrbk
      nftables
      nix-tree
      nmap
      nur-xddxdd.lantianCustomized.nixos-cleanup
      nur-xddxdd.lantianCustomized.x86-arch-level
      openssl
      pciutils
      pigz
      pv
      restic
      ripgrep
      rsync
      screen
      speedtest-cli
      sqlite
      strace
      tcpdump
      unzip
      usbutils
      wget
      wireguard-tools
      zip
      zstd
    ]
    ++ (if (LT.this.hasTag LT.tags.server) then [ python3 ] else [ python3Full ])
    ++ (
      if (!LT.this.hasTag LT.tags.qemu) then
        [
          ethtool
          lm_sensors
          nur-xddxdd.lantianCustomized.ls-iommu
          smartmontools
        ]
      else
        [ ]
    );

  hardware.ksm.enable = !config.boot.isContainer;

  lantian.qemu-user-static-binfmt.package = pkgs.nur-xddxdd.qemu-user-static;

  programs = {
    bash.vteIntegration = LT.this.hasTag LT.tags.client;
    command-not-found.enable = false;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    less = {
      enable = true;
      lessopen = null;
    };
    mtr.enable = true;
    traceroute.enable = true;

    fuse = {
      mountMax = 32767;
      userAllowOther = true;
    };

    steam.platformOptimizations.enable = true;
  };

  services.ananicy = {
    enable = LT.this.hasTag LT.tags.client;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  services.fstrim.enable = !config.boot.isContainer;
  services.irqbalance.enable = !config.boot.isContainer;

  services.journald.extraConfig = ''
    ForwardToConsole=no
    ForwardToKMsg=no
    ForwardToWall=no
    Storage=persistent
    SystemMaxFileSize=10M
    SystemMaxUse=100M
  '';

  security.openssl = {
    oqs-provider = {
      enable = true;
      package = pkgs.nur-xddxdd.openssl-oqs-provider;
      curves = [
        # Client: use generic curves first before OQS ones
        "x25519"
        "prime256v1"
        "x448"
        "secp521r1"
        "secp384r1"
        # OQS curves
        "x25519_frodo640aes"
        "p256_frodo640aes"
        "x25519_bikel1"
        "p256_bikel1"
      ];
    };
    gost-engine = {
      enable = true;
      package = pkgs.nur-xddxdd.gost-engine;
    };
  };

  security.wrappers = {
    bwrap = {
      source = pkgs.bubblewrap + "/bin/bwrap";
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
    netns-exec = {
      source = pkgs.nur-xddxdd.netns-exec + "/bin/netns-exec";
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
    netns-exec-dbus = {
      source = pkgs.nur-xddxdd.netns-exec + "/bin/netns-exec-dbus";
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
  };

  system.disableInstallerTools = !LT.this.hasTag LT.tags.client;
  system.fsPackages = [ pkgs.bindfs ];

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = LT.this.hasTag LT.tags.client;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };

    oomd.enable = lib.mkForce false;

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';

    # https://github.com/systemd/systemd/issues/25376
    extraConfig = ''
      DefaultOOMPolicy=continue
      DefaultTimeoutStopSec=30s
    '';

    tmpfiles.rules = [
      # Enables storing of the kernel log (including stack trace) into pstore upon a panic or crash.
      "w /sys/module/kernel/parameters/crash_kexec_post_notifiers - - - - Y"
      # Enables storing of the kernel log upon a normal shutdown (shutdown, reboot, halt).
      "w /sys/module/printk/parameters/always_kmsg_dump - - - - N"
    ];
  };

  systemd.services."systemd-machine-id-commit".enable = false;
}
