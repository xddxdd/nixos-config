{ config, pkgs, modules, ... }:

{
  # Set your time zone.
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.homeBinInPath = true;
  environment.variables.SYSTEMD_PAGER = "";
  environment.systemPackages = with pkgs; [
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

  # Try to workaround VM crash
  systemd.coredump.enable = false;

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

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
