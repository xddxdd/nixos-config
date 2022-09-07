{ pkgs, lib, config, ... }:

lib.mkIf (!config.boot.isContainer) {
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
        nvlax = pkgs.callPackage ./nvlax.nix { };
      in
      kpkg.extend (final: prev: {
        acpi-ec = final.callPackage ./acpi-ec.nix { };
        nullfsvfs = final.callPackage ./nullfsvfs.nix { };

        nvidia_x11 = prev.nvidia_x11.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            ${nvlax}/bin/nvlax_fbc \
              -i $out/lib/libnvidia-fbc.so.${old.version} \
              -o $out/lib/libnvidia-fbc.so.${old.version}
            ${nvlax}/bin/nvlax_encode \
              -i $out/lib/libnvidia-encode.so.${old.version} \
              -o $out/lib/libnvidia-encode.so.${old.version}
          '';
        });
      });
    kernelModules = [ "cryptodev" "nullfs" ];
    extraModulePackages = with config.boot.kernelPackages; [
      cryptodev
      nullfsvfs
    ];

    initrd = {
      inherit (config.boot) kernelModules;

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

      # https://askubuntu.com/a/402940/1038244
      "vm.oom_kill_allocating_task" = 1;
    };

    supportedFilesystems = [
      "ntfs"
    ];
  };

  fileSystems."/run/nullfs" = {
    device = "nullfs";
    fsType = "nullfs";
    options = [ "noatime" "mode=777" "nosuid" "nodev" "noexec" ];
  };
}
