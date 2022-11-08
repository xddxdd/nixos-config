{ pkgs, lib, config, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  kpkg =
    if pkgs.stdenv.isx86_64 then
      pkgs.linuxPackagesFor pkgs.lantianCustomized.linux-xanmod-lantian-lto
    else pkgs.linuxPackages_latest;
  llvmOverride = p:
    if pkgs.stdenv.isx86_64 then
      p.overrideAttrs
        (old: {
          makeFlags = (old.makeFlags or [ ]) ++ [ "LLVM=1" "LLVM_IAS=1" ];
        }) else p;
  nvidiaOverride = p: llvmOverride (p.overrideAttrs (old: {
    # Somehow fixup phase is ran twice
    postFixup = (old.postFixup or "") + ''
      SED_ENCODE=$(cat "${LT.sources.nvidia-patch.src}/patch.sh" \
        | grep '"${old.version}"' \
        | head -n1 \
        | cut -d"'" -f2)
      SED_FBC=$(cat "${LT.sources.nvidia-patch.src}/patch-fbc.sh" \
        | grep '"${old.version}"' \
        | head -n1 \
        | cut -d"'" -f2)

      echo "Patch $out/lib/libnvidia-encode.so.${old.version}"
      sed -i "$SED_ENCODE" "$out/lib/libnvidia-encode.so.${old.version}"
      LANG=C grep -obUaP "$(echo "$SED_ENCODE" | cut -d'/' -f3)" "$out/lib/libnvidia-encode.so.${old.version}"

      echo "Patch $out/lib/libnvidia-fbc.so.${old.version}"
      sed -i "$SED_FBC" "$out/lib/libnvidia-fbc.so.${old.version}"
      LANG=C grep -obUaP "$(echo "$SED_FBC" | cut -d'/' -f3)" "$out/lib/libnvidia-fbc.so.${old.version}"
    '';
  }));
in
lib.mkIf (!config.boot.isContainer) {
  boot = {
    kernelParams = [
      "audit=0"
      "cgroup_enable=memory"
      "net.ifnames=0"
      "swapaccount=1"
    ];
    kernelPackages = kpkg.extend (final: prev: {
      acpi-ec = llvmOverride (final.callPackage ./acpi-ec.nix { });
      cryptodev = llvmOverride prev.cryptodev;
      kvmfr = llvmOverride prev.kvmfr;
      nullfsvfs = llvmOverride (final.callPackage ./nullfsvfs.nix { });
      ovpn-dco = llvmOverride (final.callPackage ./ovpn-dco.nix { });
      v4l2loopback = llvmOverride prev.v4l2loopback;
      virtualbox = llvmOverride prev.virtualbox;
      x86_energy_perf_policy = (llvmOverride prev.x86_energy_perf_policy).overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace Makefile \
            --replace "gcc" "cc"
        '';
      });

      # Build failure on latest nixpkgs
      nvidia_x11 = nvidiaOverride prev.nvidia_x11;
      nvidiaPackages = lib.mapAttrs (k: nvidiaOverride) prev.nvidiaPackages;
    });
    kernelModules = [ "cryptodev" "nullfs" "ovpn-dco" ];
    extraModulePackages = with config.boot.kernelPackages; [
      cryptodev
      nullfsvfs
      ovpn-dco
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
