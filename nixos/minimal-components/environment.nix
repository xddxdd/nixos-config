{
  pkgs,
  lib,
  LT,
  inputs,
  ...
}:
{
  age.secrets.default-pw = {
    file = inputs.secrets + "/default-pw.age";
    mode = "0444";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
  ];

  environment.homeBinInPath = true;
  environment.localBinInPath = true;
  environment.variables = {
    # keep-sorted start
    DXVK_LOG_PATH = "none";
    DXVK_STATE_CACHE_PATH = "/tmp";
    LD_PRELOAD = "${pkgs.nur-xddxdd.env-dedup}/lib/libenv_dedup.so";
    NIXPKGS_ALLOW_INSECURE = "1";
    NIX_REMOTE = "daemon";
    OLLAMA_HOST = "http://ollama.localhost";
    SYSTEMD_PAGER = "";
    # keep-sorted end
  };

  environment.defaultPackages = [ ];
  environment.systemPackages = with pkgs; [
    # keep-sorted start
    bat
    bridge-utils
    curl
    dig
    duf
    e2fsprogs # chattr, lsattr
    ethtool
    eza
    fuc
    fzf
    gitMinimal
    gzip
    inetutils
    iperf3
    iw
    lm_sensors
    lsof
    mbuffer # required for btrbk
    nettools
    nix-tree
    nmap
    nur-xddxdd.lantianCustomized.ls-iommu
    nur-xddxdd.lantianCustomized.nixos-cleanup
    nur-xddxdd.lantianCustomized.x86-arch-level
    openssl
    pciutils
    pigz
    pv
    python3
    restic
    ripgrep
    rsync
    screen
    smartmontools
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
    # keep-sorted end
  ];

  hardware.ksm.enable = true;

  lantian.qemu-user-static-binfmt = {
    enable = LT.this.hasTag LT.tags.nix-builder || LT.this.hasTag LT.tags.client;
    package = pkgs.nur-xddxdd.qemu-user-static;
  };

  programs = {
    bash.vteIntegration = LT.this.hasTag LT.tags.client;
    command-not-found.enable = false;
    htop.enable = true;
    iftop.enable = true;
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

  services.dbus.implementation = "broker";

  services.fstrim.enable = true;
  services.irqbalance.enable = LT.this.cpuThreads > 1;

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
        "X25519MLKEM768"
        "SecP256r1MLKEM768"
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

    oomd.enable = lib.mkForce false;

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';

    # https://github.com/systemd/systemd/issues/25376
    settings.Manager = {
      DefaultOOMPolicy = "continue";
      DefaultTimeoutStopSec = "30s";

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      #
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      RuntimeWatchdogSec = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      RebootWatchdogSec = "30s";
    };

    tmpfiles.settings = {
      "pstore-log" = {
        # Enables storing of the kernel log (including stack trace) into pstore upon a panic or crash.
        "/var/lib/systemd/pstore"."d" = {
          mode = "0755";
          user = "root";
          group = "root";
        };
      };
      "crash-kexec-post-notifiers" = {
        "/sys/module/kernel/parameters/crash_kexec_post_notifiers"."w" = {
          argument = "Y";
        };
      };
      "always-kmsg-dump" = {
        # Enables storing of the kernel log upon a normal shutdown (shutdown, reboot, halt).
        "/sys/module/printk/parameters/always_kmsg_dump"."w" = {
          argument = "Y";
        };
      };
    };
  };

  systemd.services."systemd-machine-id-commit".enable = false;
}
