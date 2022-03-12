{ pkgs, config, ... }:

{
  config.boot = {
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
