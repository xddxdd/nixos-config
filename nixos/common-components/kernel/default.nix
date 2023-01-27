{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  kpkg =
    if pkgs.stdenv.isx86_64
    then pkgs.linuxPackagesFor pkgs.lantianCustomized.linux-xanmod-lantian-lto
    else pkgs.linuxPackages_latest;
  llvmOverride = p:
    if pkgs.stdenv.isx86_64 then
      p.overrideAttrs
        (old: {
          makeFlags = (old.makeFlags or [ ]) ++ [ "LLVM=1" "LLVM_IAS=1" ];
        }) else p;
  makefileOverride = p: p.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace Makefile \
        --replace "gcc" "cc"
    '';
  });
  nvidiaOverride = p:
    let
      patched = llvmOverride (p.overrideAttrs (old: {
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
    patched.overrideAttrs (old: {
      passthru = old.passthru // {
        settings = old.passthru.settings.override { nvidia_x11 = patched; };
        persistenced = old.passthru.persistenced.override { nvidia_x11 = patched; };
      };
    });
in
lib.mkIf (!config.boot.isContainer) {
  boot = {
    kernelParams = [
      "audit=0"
      "cgroup_enable=memory"
      "delayacct"
      "log_buf_len=1048576"
      "split_lock_detect=off"
      "swapaccount=1"
    ] ++ (lib.optionals (!config.networking.usePredictableInterfaceNames) [
      "net.ifnames=0"
    ]);
    kernelPackages = kpkg.extend
      (final: prev: rec {
        # Fixes for kernel modules that don't use kernel.makeFlags
        cryptodev = llvmOverride prev.cryptodev;
        kvmfr = llvmOverride prev.kvmfr;
        virtualbox = llvmOverride prev.virtualbox;
        turbostat = makefileOverride (llvmOverride prev.turbostat);
        x86_energy_perf_policy = makefileOverride (llvmOverride prev.x86_energy_perf_policy);

        # Custom kernel packages
        acpi-ec = final.callPackage ./acpi-ec.nix { };
        i915-sriov = final.callPackage ./i915-sriov.nix { };
        nft-fullcone = final.callPackage ./nft-fullcone.nix { };
        nullfsvfs = final.callPackage ./nullfsvfs.nix { };
        ovpn-dco = final.callPackage ./ovpn-dco.nix { };

        # Patched NVIDIA drivers
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/linux-kernels.nix#L355
        nvidiaPackages = lib.mapAttrs (k: nvidiaOverride) prev.nvidiaPackages;

        nvidia_x11 = nvidiaPackages.stable;
        nvidia_x11_beta = nvidiaPackages.beta;
        nvidia_x11_legacy340 = nvidiaPackages.legacy_340;
        nvidia_x11_legacy390 = nvidiaPackages.legacy_390;
        nvidia_x11_legacy470 = nvidiaPackages.legacy_470;
        nvidia_x11_production = nvidiaPackages.production;
        nvidia_x11_vulkan_beta = nvidiaPackages.vulkan_beta;

        # this is not a replacement for nvidia_x11*
        # only the opensource kernel driver exposed for hydra to build
        nvidia_x11_beta_open = nvidiaPackages.beta.open;
        nvidia_x11_production_open = nvidiaPackages.production.open;
        nvidia_x11_stable_open = nvidiaPackages.stable.open;
        nvidia_x11_vulkan_beta_open = nvidiaPackages.vulkan_beta.open;
      });
    kernelModules = [
      "cryptodev"
      "nft_fullcone"
      "nullfs"

      # Disabled for incompatibility with 6.1 kernel
      # "ovpn-dco"
    ]
    ++ lib.optionals pkgs.stdenv.isx86_64 [ "winesync" ];
    extraModulePackages = with config.boot.kernelPackages; [
      cryptodev

      # Disabled for crashing on latest kernel
      # i915-sriov

      nft-fullcone
      nullfsvfs

      # Disabled for incompatibility with 6.1 kernel
      # ovpn-dco
    ];

    initrd = {
      inherit (config.boot) kernelModules;

      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      systemd.enable = true;
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

  environment.systemPackages = with config.boot.kernelPackages; lib.optionals pkgs.stdenv.isx86_64 [
    turbostat
  ];

  fileSystems."/run/nullfs" = {
    device = "nullfs";
    fsType = "nullfs";
    options = [ "noatime" "mode=777" "nosuid" "nodev" "noexec" ];
  };

  services.udev.extraRules = ''
    KERNEL=="winesync", MODE="0644"
  '';
}
