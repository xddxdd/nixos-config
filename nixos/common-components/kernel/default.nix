{ pkgs, lib, config, ... }:

{
  boot = {
    kernelParams = [
      "audit=0"
      "cgroup_enable=memory"
      "net.ifnames=0"
      "swapaccount=1"
    ];
    kernelPackages =
      let
        kpkg =
          if pkgs.stdenv.isx86_64 then
            pkgs.linuxPackagesFor pkgs.lantianCustomized.linux-xanmod-lantian
          else pkgs.linuxPackages_latest;
      in
      kpkg.extend (final: prev: {
        acpi-ec = final.callPackage ./acpi-ec.nix { };
      });
    kernelModules = [ "cryptodev" ];
    extraModulePackages = with config.boot.kernelPackages; [
      cryptodev
    ];

    initrd = {
      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      includeDefaultModules = false;
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
}
