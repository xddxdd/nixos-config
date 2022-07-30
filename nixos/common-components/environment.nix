{ config, pkgs, lib, modules, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

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
    file = pkgs.secrets + "/default-pw.age";
    mode = "0444";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.homeBinInPath = true;
  environment.localBinInPath = true;
  environment.variables = {
    KOPIA_CHECK_FOR_UPDATES = "false";
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
    nftables
    nix-prefetch
    openssl
    p7zip
    pciutils
    pigz
    pv
    pwgen
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
    nix-alien
    nix-index
    nix-index-update
    (python3Full.withPackages (p: with p; [
      autopep8
      pip
      requests
    ]))
    rar # Doesn't suppport aarch64 for some reason
    x86-arch-level
  ] else [
    python3Full
  ]);

  home-manager.backupFileExtension = "bak";

  programs = {
    #atop.enable = true;
    #atop.netatop.enable = true;
    bash.vteIntegration = true;
    iftop.enable = true;
    iotop.enable = true;
    less.enable = true;
    mosh.enable = true;
    mtr.enable = true;
    nix-ld.enable = pkgs.stdenv.isx86_64;
    ssh.forwardX11 = true;
    traceroute.enable = true;
  };

  security.dhparams.defaultBitSize = 4096;
  security.protectKernelImage = true;
  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults lecture="never"
    '';
  };

  services.ananicy = {
    enable = !config.boot.isContainer;
    package = pkgs.ananicy-cpp;
  };

  services.earlyoom = {
    enable = !config.boot.isContainer;
    enableNotifications = LT.this.role == LT.roles.client;
    freeMemThreshold = 3;
    freeMemKillThreshold = 2;
    freeSwapThreshold = 3;
    freeSwapKillThreshold = 2;
  };

  services.irqbalance.enable = !config.boot.isContainer;

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

  zramSwap = {
    enable = !config.boot.isContainer;
    memoryPercent = 50;
  };
}
