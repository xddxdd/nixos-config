{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  llvmOverride = p:
    if pkgs.stdenv.isx86_64
    then
      p.overrideAttrs
      (old: {
        makeFlags = (old.makeFlags or []) ++ ["LLVM=1" "LLVM_IAS=1"];
      })
    else p;
  makefileOverride = p:
    p.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace Makefile \
            --replace "gcc" "cc"
        '';
    });
  nvidiaOverride = p: let
    patched = llvmOverride (p.overrideAttrs (old: {
      # Somehow fixup phase is ran twice
      postFixup =
        (old.postFixup or "")
        + ''
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
      passthru =
        old.passthru
        // {
          settings = old.passthru.settings.override {nvidia_x11 = patched;};
          persistenced = old.passthru.persistenced.override {nvidia_x11 = patched;};
        };
    });
in {
  options = {
    lantian.kernel = lib.mkOption {
      type = lib.types.package;
      default =
        if pkgs.stdenv.isx86_64
        then
          (
            if builtins.elem LT.tags.x86_64-v1 LT.this.tags
            then pkgs.lantianLinuxXanmod.x86_64-v1-lto
            else pkgs.lantianLinuxXanmod.x86_64-v3-lto
          )
        else pkgs.linux_6_1;
    };
  };
  config = {
    boot = {
      kernelParams =
        [
          "audit=0"
          "cgroup_enable=memory"
          "delayacct"
          "ibt=off"
          "log_buf_len=1048576"
          "nvme_core.default_ps_max_latency_us=2147483647"
          "split_lock_detect=off"
          "swapaccount=1"
        ]
        ++ (lib.optionals (!config.networking.usePredictableInterfaceNames) [
          "net.ifnames=0"
        ]);
      kernelPackages =
        (pkgs.linuxPackagesFor config.lantian.kernel).extend
        (final: prev: rec {
          # Fixes for kernel modules that don't use kernel.makeFlags
          cryptodev = llvmOverride prev.cryptodev;
          kvmfr = llvmOverride prev.kvmfr;
          virtualbox = llvmOverride prev.virtualbox;
          turbostat = makefileOverride (llvmOverride prev.turbostat);
          x86_energy_perf_policy = makefileOverride (llvmOverride prev.x86_energy_perf_policy);

          # Custom kernel packages
          acpi-ec = final.callPackage ./acpi-ec.nix {};
          i915-sriov = final.callPackage ./i915-sriov.nix {};
          nft-fullcone = final.callPackage ./nft-fullcone.nix {};
          nullfsvfs = final.callPackage ./nullfsvfs.nix {};
          ovpn-dco = final.callPackage ./ovpn-dco.nix {};

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

          nvidia_x11_vgpu = nvidiaPackages.stable.overrideAttrs (old: rec {
            name = "nvidia-x11-${version}-${final.kernel.version}";
            version = "525.85.07";
            src = pkgs.requireFile rec {
              name = "NVIDIA-Linux-x86_64-${version}-vgpu-kvm.run";
              sha256 = "0f4h2wlsbbi59z9jyz4drlslmgmiairnfiw3ahybmgl8lapzhvdy";
              url = "https://www.nvidia.com/object/vGPU-software-driver.html";
              message = ''
                Unfortunately, we cannot download file ${name} automatically.
                This file can be extracted from vGPU driver's zip file.
                Please go to ${url} to download it yourself, and add it to the Nix store
                using either
                  nix-store --add-fixed sha256 ${name}
                or
                  nix-prefetch-url --type sha256 file:///path/to/${name}
              '';
            };
          });

          # this is not a replacement for nvidia_x11*
          # only the opensource kernel driver exposed for hydra to build
          nvidia_x11_beta_open = nvidiaPackages.beta.open;
          nvidia_x11_production_open = nvidiaPackages.production.open;
          nvidia_x11_stable_open = nvidiaPackages.stable.open;
          nvidia_x11_vulkan_beta_open = nvidiaPackages.vulkan_beta.open;
        });
      kernelModules =
        [
          "cryptodev"
          "nft_fullcone"
          "nullfs"
          # Temporarily disabled for build failure
          # "ovpn-dco"
        ]
        ++ lib.optionals pkgs.stdenv.isx86_64 ["winesync"];
      extraModulePackages = with config.boot.kernelPackages; ([
          cryptodev
          nft-fullcone
          nullfsvfs
          ovpn-dco
        ]
        ++ lib.optionals (builtins.elem LT.tags.i915-sriov LT.this.tags) [
          i915-sriov
        ]);

      initrd = {
        kernelModules = ["nullfs"];

        compressor = "zstd";
        compressorArgs = ["-19" "-T0"];
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
        "vm.swappiness" = 10;
      };

      supportedFilesystems = [
        "ntfs"
      ];
    };

    environment.systemPackages = with config.boot.kernelPackages;
      lib.optionals pkgs.stdenv.isx86_64 [
        turbostat
      ];

    fileSystems."/run/nullfs" = {
      device = "nullfs";
      fsType = "nullfs";
      options = ["noatime" "mode=777" "nosuid" "nodev" "noexec"];
    };

    services.udev.extraRules = ''
      KERNEL=="winesync", MODE="0644"
    '';

    systemd.services.i915-sriov = {
      enable = builtins.elem LT.tags.i915-sriov LT.this.tags;
      description = "Enable i915 SRIOV";
      wantedBy = ["multi-user.target"];
      after = ["systemd-modules-load.service"];
      requires = ["systemd-modules-load.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        I915_PATH=/sys/devices/pci0000:00/0000:00:02.0
        NUMVFS=$(cat "$I915_PATH/sriov_totalvfs")
        echo 0 > "$I915_PATH/sriov_drivers_autoprobe"
        echo "$NUMVFS" > "$I915_PATH/sriov_numvfs"

        ${pkgs.kmod}/bin/modprobe -v vfio-pci

        for VF in $I915_PATH/virtfn*; do
          PCI_ADDR=$(readlink -f $VF)
          PCI_ADDR=''${PCI_ADDR##*/}
          echo vfio-pci > "$VF/driver_override"
          echo "$PCI_ADDR" > /sys/bus/pci/drivers_probe
        done
      '';
    };

    systemd.services.systemd-sysctl = {
      after = ["bin.mount"];
      requires = ["bin.mount"];
      serviceConfig = {
        Restart = "on-failure";
      };
    };
  };
}
