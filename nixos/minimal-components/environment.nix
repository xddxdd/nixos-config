{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  # https://gist.github.com/r15ch13/ba2d738985fce8990a4e9f32d07c6ada
  ls-iommu = pkgs.writeShellScriptBin "ls-iommu" ''
    shopt -s nullglob
    lastgroup=""
    for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
        for d in $g/devices/*; do
            if [ "''${g##*/}" != "$lastgroup" ]; then
                echo -en "Group ''${g##*/}:\t"
            else
                echo -en "\t\t"
            fi
            lastgroup=''${g##*/}
            lspci -nms ''${d##*/} | awk -F'"' '{printf "[%s:%s]", $4, $6}'
            if [[ -e "$d"/reset ]]; then echo -en " [R] "; else echo -en "     "; fi

            lspci -mms ''${d##*/} | awk -F'"' '{printf "%s %-40s %s\n", $1, $2, $6}'
            for u in ''${d}/usb*/; do
                bus=$(cat "''${u}/busnum")
                lsusb -s $bus: | \
                    awk '{gsub(/:/,"",$4); printf "%s|%s %s %s %s|", $6, $1, $2, $3, $4; for(i=7;i<=NF;i++){printf "%s ", $i}; printf "\n"}' | \
                    awk -F'|' '{printf "USB:\t\t[%s]\t\t %-40s %s\n", $1, $2, $3}'
            done
        done
    done
  '';

  nixos-cleanup = pkgs.writeScriptBin "nixos-cleanup" ''
    ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +1
    ${config.nix.package}/bin/nix-env -p /root/.local/state/nix/profiles/home-manager --delete-generations +1
    ${config.nix.package}/bin/nix-env -p /home/lantian/.local/state/nix/profiles/home-manager --delete-generations +1
    ${config.nix.package}/bin/nix-collect-garbage -d
  '';

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
in
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
      fzf
      gitMinimal
      gzip
      inetutils
      iperf3
      iptables
      iw
      kopia
      lsof
      mbuffer
      nftables
      nix-tree
      nixos-cleanup
      nmap
      openssl
      pciutils
      pigz
      pv
      restic
      ripgrep
      rsync
      screen
      speedtest-cli
      strace
      tcpdump
      unzip
      usbutils
      wget
      wireguard-tools
      x86-arch-level
      zip
      zstd
    ]
    ++ (if (LT.this.hasTag LT.tags.server) then [ python3 ] else [ python3Full ])
    ++ (
      if (!LT.this.hasTag LT.tags.qemu) then
        [
          ethtool
          lm_sensors
          ls-iommu
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

    openssl-oqs-provider = {
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

  services.userborn = {
    enable = true;
    passwordFilesLocation = "/var/lib/nixos";
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

  system.etc.overlay = {
    enable = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.6";
    mutable = true;
  };

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
