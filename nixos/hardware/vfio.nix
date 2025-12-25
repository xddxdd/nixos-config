{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.lantian.vfio;
in
{
  options.lantian.vfio = {
    ids = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    blacklistedModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    isolcpus = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = {
    boot.kernelModules = [
      "vfio-pci"
    ];
    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "amd_iommu=on"
      "pcie_acs_override=downstream,multifunction"
    ]
    ++ lib.optionals (cfg.isolcpus != null) [
      "isolcpus=${cfg.isolcpus}"
      "nohz_full=${cfg.isolcpus}"
      "rcu_nocbs=${cfg.isolcpus}"
    ];
    boot.extraModprobeConfig = ''
      softdep drm pre: vfio-pci
      softdep nvidia pre: vfio-pci
      options vfio-pci disable_denylist=1 ids=${lib.concatStringsSep "," cfg.ids}
    ''
    + (lib.concatMapStringsSep "\n" (n: ''
      blacklist ${n}
      install ${n} ${pkgs.coreutils}/bin/true
    '') cfg.blacklistedModules);
  };
}
