{ pkgs, config, options, ... }:

{
  options.lantian.enableGUI = pkgs.lib.mkEnableOption "enableGUI";

  config.boot = {
    kernelParams = [
      "audit=0"
      "cgroup_enable=memory"
      "net.ifnames=0"
      "swapaccount=1"
      "syscall.x32=y"
    ] ++ pkgs.lib.optionals config.lantian.enableGUI [
      "nofb"
      "nomodeset"
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
          "netboot.xyz.lkrn" = ../files/netboot.xyz.lkrn;
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

}
