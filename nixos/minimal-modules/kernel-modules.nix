{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.boot = {
    availableKernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Kernel modules to retain without loading when pruning the system module tree.";
    };
    pruneKernelModules = lib.mkEnableOption "retaining only declared kernel modules and their dependencies";
  };

  config = lib.mkIf config.boot.pruneKernelModules {
    system.modulesTree = lib.mkForce [
      (
        (pkgs.makeModulesClosure {
          kernel = pkgs.aggregateModules (
            [ (lib.getOutput "modules" config.boot.kernelPackages.kernel) ] ++ config.boot.extraModulePackages
          );
          firmware = config.hardware.firmware;
          rootModules = lib.unique (
            config.boot.availableKernelModules
            ++ config.boot.kernelModules
            ++ config.boot.initrd.availableKernelModules
            ++ config.boot.initrd.kernelModules
          );
          allowMissing = false;
        }).overrideAttrs
        (old: {
          # The initrd closes this tree again; its builder needs the original
          # built-in metadata and ordering hints that makeModulesClosure removes.
          builder = pkgs.writeText "modules-closure-with-metadata.sh" ''
            source ${old.builder}
            cp "$kernel/lib/modules/$version/"{modules.order,modules.builtin,modules.builtin.modinfo,modules.cer} \
              "$out/lib/modules/$version/"
            if [ -d "$kernel/etc/depmod.d" ]; then
              mkdir -p "$out/etc"
              cp -rL "$kernel/etc/depmod.d" "$out/etc/"
            fi
          '';
        })
      )
    ];
  };
}
