{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  # https://unix.stackexchange.com/a/631226
  x86-arch-level = pkgs.writeScriptBin "x86-arch-level" ''
    #!${pkgs.gawk}/bin/awk -f

    BEGIN {
      while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
      if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
      if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
      if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
      if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
      if (level > 0) { print "CPU supports x86-64-v" level; exit level + 1 }
      exit 1
    }
  '';

  opensslCurves = [
    "p256_frodo640aes"
    "x25519_frodo640aes"
    "p256_bikel1"
    "x25519_bikel1"
    "p256_kyber90s512"
    "x25519_kyber90s512"
    "prime256v1"
    "secp384r1"
    "x25519"
    "x448"
  ];

  pythonCustomized = pkgs.python3Full.withPackages (p: with p; (if pkgs.stdenv.isx86_64 then [
    autopep8
  ] else [ ]) ++ [
    pip
    requests
    numpy
    matplotlib
  ]);
in
{
  age.secrets.default-pw = {
    file = inputs.secrets + "/default-pw.age";
    mode = "0444";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "all" ];

  location = {
    provider = if builtins.elem LT.tags.client LT.this.tags then "geoclue2" else "manual";
    latitude = LT.this.city.lat;
    longitude = LT.this.city.lng;
  };

  environment.homeBinInPath = true;
  environment.localBinInPath = true;
  environment.variables = {
    DXVK_LOG_PATH = "none";
    DXVK_STATE_CACHE_PATH = "/tmp";
    ENVFS_RESOLVE_ALWAYS = "1";
    KOPIA_CHECK_FOR_UPDATES = "false";
    OPENSSL_CONF = builtins.toString (pkgs.writeText "openssl.conf" ''
      openssl_conf = openssl_init

      [openssl_init]
      providers = provider_sect
      ssl_conf = ssl_sect

      ### Providers

      [provider_sect]
      oqsprovider = oqsprovider_sect
      default = default_sect
      # fips = fips_sect

      [default_sect]
      activate = 1

      #[fips_sect]
      #activate = 1

      [oqsprovider_sect]
      activate = 1
      module = ${pkgs.openssl-oqs-provider}/lib/oqsprovider.so

      # SSL Options

      [ssl_sect]
      system_default = system_default_sect

      [system_default_sect]
      Groups = ${builtins.concatStringsSep ":" opensslCurves}
    '');
    SYSTEMD_PAGER = "";
  };
  environment.systemPackages = with pkgs; [
    brotli
    bzip2
    dig
    git
    gzip
    htop
    inetutils
    iptables
    jq
    kopia
    lbzip2
    lsof
    nftables-fullcone
    nix-prefetch
    openssl
    p7zip
    pciutils
    pigz
    pv
    pwgen
    pythonCustomized
    screen
    smartmontools
    tcpdump
    unar
    unrar
    unzip
    usbutils
    wget
    wireguard-tools
    zip
    zstd
  ] ++ (if pkgs.stdenv.isx86_64 then [
    nix-index
    nix-index-update
    rar # Doesn't suppport aarch64 for some reason
    x86-arch-level
  ] else [ ]);

  hardware.ksm.enable = !config.boot.isContainer;

  programs = {
    #atop.enable = true;
    #atop.netatop.enable = true;
    bash.vteIntegration = true;
    iftop.enable = true;
    iotop.enable = true;
    less.enable = true;
    mosh.enable = true;
    mtr.enable = true;
    traceroute.enable = true;

    fuse = {
      mountMax = 32767;
      userAllowOther = true;
    };
  };

  security.protectKernelImage = true;
  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults lecture="never"
    '';
  };

  services.envfs.enable = true;
  services.fstrim.enable = !config.boot.isContainer;
  services.irqbalance.enable = !config.boot.isContainer;

  services.journald.extraConfig = ''
    Audit=no
    ForwardToConsole=no
    ForwardToKMsg=no
    ForwardToSyslog=no
    ForwardToWall=no
    Storage=volatile
    SystemMaxFileSize=10M
    SystemMaxUse=10M
  '';

  services.udisks2.enable = !config.boot.isContainer;

  security.wrappers = {
    bwrap = {
      source = pkgs.bubblewrap + "/bin/bwrap";
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
    netns-exec = {
      source = pkgs.netns-exec + "/bin/netns-exec";
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
    netns-exec-dbus = {
      source = pkgs.netns-exec + "/bin/netns-exec-dbus";
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
  };

  system.fsPackages = [ pkgs.bindfs ];

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = builtins.elem LT.tags.client LT.this.tags;

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

  zramSwap = {
    enable = !config.boot.isContainer;
    memoryPercent = 50;
  };
}
