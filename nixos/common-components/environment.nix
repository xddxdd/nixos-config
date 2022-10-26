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

  pythonCustomized = pkgs.python3Full.withPackages (p: with p; (if pkgs.stdenv.isx86_64 then [
    autopep8
  ] else [ ]) ++ [
    pip
    requests
    numpy
    scipy
    matplotlib
  ]);
in
{
  age.secrets.default-pw = {
    file = pkgs.secrets + "/default-pw.age";
    mode = "0444";
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.homeBinInPath = true;
  environment.localBinInPath = true;
  environment.variables = {
    DXVK_LOG_PATH = "none";
    DXVK_STATE_CACHE_PATH = "/tmp";
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
      Groups = prime256v1:secp384r1:secp521r1:X25519:X448:p256_frodo640aes:p256_bikel1:p256_ntru_hps2048509:p256_lightsaber:p256_kyber90s512
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
    nftables
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
    ssh.forwardX11 = true;
    traceroute.enable = true;
  };

  security.protectKernelImage = true;
  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults lecture="never"
    '';
  };

  services.irqbalance.enable = !config.boot.isContainer;

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

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=30s
  '';

  zramSwap = {
    enable = !config.boot.isContainer;
    memoryPercent = 50;
  };
}
