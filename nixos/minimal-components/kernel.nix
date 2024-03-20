{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  myKernelPackageFor =
    kernel:
    let
      # ccacheKernelStdenv = let
      #   newStdenv = pkgs.overrideCC kernel.stdenv (pkgs.ccacheWrapper.override {
      #     inherit (kernel.stdenv) cc;
      #   });
      #   mkCCachePlatform = platform:
      #     platform
      #     // {
      #       linux-kernel =
      #         platform.linux-kernel
      #         // {
      #           makeFlags =
      #             (platform.linux-kernel.makeFlags or [])
      #             ++ [
      #               "CC=${newStdenv.cc}/bin/cc"
      #               "HOSTCC=${newStdenv.cc}/bin/cc"
      #               "HOSTCXX=${newStdenv.cc}/bin/c++"
      #             ];
      #         };
      #     };
      # in
      #   newStdenv.override {
      #     hostPlatform = mkCCachePlatform newStdenv.hostPlatform;
      #     buildPlatform = mkCCachePlatform newStdenv.buildPlatform;
      #   };
      # ccacheKernel = kernel.override {
      #   stdenv = ccacheKernelStdenv;
      #   buildPackages =
      #     pkgs.buildPackages
      #     // {
      #       stdenv = ccacheKernelStdenv;
      #     };
      # };
      kernelPackages = pkgs.linuxKernel.packagesFor kernel;

      llvmOverride =
        kernelPackages_:
        kernelPackages_.extend (
          final: prev:
          lib.mapAttrs (
            n: v:
            if
              kernelPackages_.kernel.stdenv.cc.bintools.isLLVM
              && !(builtins.elem n [ "kernel" ])
              && lib.isDerivation v
              && ((v.overrideAttrs or null) != null)
            then
              v.overrideAttrs (old: {
                makeFlags =
                  (old.makeFlags or [ ]) ++ kernelPackages_.kernel.stdenv.buildPlatform.linux-kernel.makeFlags;
                postPatch =
                  (if (old.postPatch or null) == null then "" else old.postPatch)
                  + ''
                    if [ -f Makefile ]; then
                      substituteInPlace Makefile --replace "gcc" "cc"
                    fi
                  '';
              })
            else
              v
          ) prev
        );

      nvidiaOverride =
        let
          patch =
            p:
            let
              patched = p.overrideAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ (with pkgs; [ llvmPackages.libunwind ]);

                # Somehow fixup phase is ran twice
                postFixup =
                  (old.postFixup or "")
                  + ''
                    # Skip patching if latest patch is not available
                    SED_ENCODE=$(cat "${LT.sources.nvidia-patch.src}/patch.sh" \
                      | grep '"${old.version}"' \
                      | head -n1 \
                      | cut -d"'" -f2 \
                      || echo "")
                    SED_FBC=$(cat "${LT.sources.nvidia-patch.src}/patch-fbc.sh" \
                      | grep '"${old.version}"' \
                      | head -n1 \
                      | cut -d"'" -f2 \
                      || echo "")

                    echo "Patch $out/lib/libnvidia-encode.so.${old.version}"
                    sed -i "$SED_ENCODE" "$out/lib/libnvidia-encode.so.${old.version}"
                    LANG=C grep -obUaP "$(echo "$SED_ENCODE" | cut -d'/' -f3)" "$out/lib/libnvidia-encode.so.${old.version}"

                    echo "Patch $out/lib/libnvidia-fbc.so.${old.version}"
                    sed -i "$SED_FBC" "$out/lib/libnvidia-fbc.so.${old.version}"
                    LANG=C grep -obUaP "$(echo "$SED_FBC" | cut -d'/' -f3)" "$out/lib/libnvidia-fbc.so.${old.version}"
                  '';
              });
            in
            patched.overrideAttrs (old: {
              passthru = old.passthru // {
                settings = (old.passthru.settings.override { nvidia_x11 = patched; }).overrideAttrs (old: {
                  buildInputs = (old.buildInputs or [ ]) ++ (with pkgs; [ llvmPackages.libunwind ]);
                });
                persistenced = (old.passthru.persistenced.override { nvidia_x11 = patched; }).overrideAttrs (old: {
                  buildInputs = (old.buildInputs or [ ]) ++ (with pkgs; [ llvmPackages.libunwind ]);
                });
              };
            });
        in
        kernelPackages_:
        kernelPackages_.extend (
          final: prev:
          (lib.mapAttrs (
            n: v: if lib.hasPrefix "nvidia_x11" n && lib.isDerivation v then patch v else v
          ) prev)
          // {
            nvidiaPackages = lib.mapAttrs (n: v: patch v) prev.nvidiaPackages;
          }
        );
    in
    lib.foldr (a: b: a b)
      (kernelPackages.extend (
        final: prev: {
          # Custom kernel packages
          acpi-ec = pkgs.acpi-ec.override { inherit (final) kernel; };
          cryptodev = pkgs.cryptodev-unstable.override { inherit (final) kernel; };
          dpdk-kmod = pkgs.dpdk-kmod.override { inherit (final) kernel; };
          i915-sriov = pkgs.i915-sriov.override { inherit (final) kernel; };
          nft-fullcone = pkgs.nft-fullcone.override { inherit (final) kernel; };
          nullfsvfs = pkgs.nullfsvfs.override { inherit (final) kernel; };
          ovpn-dco = pkgs.ovpn-dco.override { inherit (final) kernel; };
          r8125 = pkgs.r8125.override { inherit (final) kernel; };
          r8168 = pkgs.r8168.override { inherit (final) kernel; };

          nvidia_x11_grid_16_2 = pkgs.nvidia-grid.grid."16_2".override { inherit (final) kernel; };
        }
      ))
      [
        llvmOverride
        nvidiaOverride
      ];
in
{
  options = {
    lantian.kernel = lib.mkOption {
      type = lib.types.attrs;
      default =
        if pkgs.stdenv.isx86_64 then
          (
            if LT.this.hasTag LT.tags.x86_64-v1 then
              pkgs.lantianLinuxXanmod.lts-x86_64-v1-lto
            else
              pkgs.lantianLinuxXanmod.lts-x86_64-v3-lto
          )
        else
          pkgs.linux_6_6;
    };
  };
  config = {
    boot = {
      kernelParams = [
        "cgroup_enable=memory"
        "delayacct"
        "ibt=off"
        "log_buf_len=1048576"
        "nvme_core.default_ps_max_latency_us=2147483647"
        "rcuupdate.rcu_cpu_stall_suppress=1"
        "split_lock_detect=off"
        "swapaccount=1"
      ] ++ (lib.optionals (!config.networking.usePredictableInterfaceNames) [ "net.ifnames=0" ]);
      kernelPackages = myKernelPackageFor config.lantian.kernel;
      kernelModules = [
        "cryptodev"
        "nft_fullcone"
        "nullfs"
        # Temporarily disabled for build failure
        # "ovpn-dco"
      ] ++ lib.optionals pkgs.stdenv.isx86_64 [ "winesync" ];
      extraModulePackages =
        with config.boot.kernelPackages;
        (
          [
            cryptodev
            nft-fullcone
            nullfsvfs
            # ovpn-dco
            r8125
            r8168
          ]
          ++ lib.optionals (LT.this.hasTag LT.tags.i915-sriov) [ i915-sriov ]
        );

      bcache.enable = false;
      initrd = {
        kernelModules = [ "nullfs" ];

        compressor = "zstd";
        compressorArgs = [
          "-19"
          "-T0"
        ];
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

        # https://github.com/NixOS/nixpkgs/pull/268121/files
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.swappiness" = if config.swapDevices != [ ] then 60 else 180;
        "vm.page-cluster" =
          if config.swapDevices != [ ] then
            3 # Kernel default
          else if config.zramSwap.algorithm == "zstd" then
            0
          else
            1;
      };

      supportedFilesystems = [ "ntfs" ];

      swraid.enable = false;
    };

    environment.systemPackages =
      with config.boot.kernelPackages;
      lib.optionals pkgs.stdenv.isx86_64 [ turbostat ];

    fileSystems."/run/nullfs" = {
      device = "nullfs";
      fsType = "nullfs";
      options = [
        "noatime"
        "mode=777"
        "nosuid"
        "nodev"
        "noexec"
      ];
    };

    services.udev.extraRules = ''
      KERNEL=="winesync", MODE="0644"
    '';

    systemd.services.i915-sriov = {
      enable = LT.this.hasTag LT.tags.i915-sriov;
      description = "Enable i915 SRIOV";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      requires = [ "systemd-modules-load.service" ];
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
      # Only use with envfs
      # after = ["bin.mount"];
      # requires = ["bin.mount"];
      serviceConfig = {
        Restart = "on-failure";
      };
    };
  };
}
