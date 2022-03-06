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
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches =
      let
        p = name: {
          inherit name; patch = ../../patches/kernel + "/${name}.patch";
        };
      in
      pkgs.lib.optionals pkgs.stdenv.isx86_64 [
        (p "0001-drm-i915-gvt-Add-virtual-option-ROM-emulation")
        (p "0003-intel-drm-use-max-clock")
        (p "0004-hp-omen-fourzone")
        (p "0008-hp-omen-mute-led")
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
