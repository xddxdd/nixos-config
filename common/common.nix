{ config, pkgs, modules, ... }:

let
  LT = import ./helpers.nix { inherit config pkgs; };
in
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    (ls ./required-apps) ++ (ls ./required-components);

  age.secrets.filebeat-elasticsearch-pw.file = ../secrets/filebeat-elasticsearch-pw.age;

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
      # https://wiki.archlinux.org/title/Security#Kernel_hardening
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 1;
      "net.core.bpf_jit_harden" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.kexec_load_disabled" = 1;

      # Disable coredump
      "fs.suid_dumpable" = 0;
      "kernel.core_pattern" = pkgs.lib.mkForce "|${pkgs.coreutils}/bin/false";

      # Other optimizations
      "kernel.nmi_watchdog" = 0;
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

  # Set your time zone.
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables = {
    SYSTEMD_PAGER = "";
  };

  environment.homeBinInPath = true;

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

  # List services that you want to enable:
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

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

  services.irqbalance.enable = true;

  services.prometheus.exporters = {
    node = {
      enable = true;
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
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
    memoryPercent = 50;
  };
}
