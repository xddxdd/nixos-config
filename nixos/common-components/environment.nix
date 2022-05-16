{ config, pkgs, lib, modules, ... }:

{
  # Set your time zone.
  time.timeZone = "America/Chicago";

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
  ] else [
    python3Full
  ]);

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
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  services.irqbalance.enable = true;

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
    enable = true;
    memoryPercent = 50;
  };
}
