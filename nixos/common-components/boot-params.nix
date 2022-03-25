{ pkgs, config, ... }:

{
  boot = {
    kernelParams = [
      "audit=0"
      "cgroup_enable=memory"
      "net.ifnames=0"
      "swapaccount=1"
      "syscall.x32=y"
    ];
    kernelPackages =
      if pkgs.stdenv.isx86_64 then
        pkgs.linuxPackagesFor pkgs.linux-xanmod-lantian
      else pkgs.linuxPackages_latest;
    kernelModules = [ "cryptodev" ];
    extraModulePackages = with config.boot.kernelPackages; [
      cryptodev
    ];

    initrd = {
      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      includeDefaultModules = false;
    };

    loader = {
      grub = {
        enable = true;
        default = "saved";
        version = 2;
        splashImage = null;
        font = pkgs.lib.mkDefault
          "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF.ttf";
        fontSize = pkgs.lib.mkDefault 16;
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

      # Other optimizations
      "kernel.nmi_watchdog" = 0;
    };
  };

  console.earlySetup = true;

  systemd.services.systemd-sysctl.serviceConfig = {
    ExecStart = [
      ""
      "/bin/sh -c \"${pkgs.systemd}/lib/systemd/systemd-sysctl; exit 0\""
    ];
  };
}
