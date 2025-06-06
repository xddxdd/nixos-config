{ pkgs, lib, ... }:
{
  boot.kernelModules = [ "vfio-pci" ];
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "amd_iommu=on"
    "isolcpus=112-127"
  ];
  boot.extraModprobeConfig =
    let
      vfioIds = [
        "10de:1b38" # NVIDIA Tesla P40
        "10de:2204" # NVIDIA RTX 3090
      ];
      blacklistedModules = [
        "nouveau"
      ];
    in
    ''
      softdep nvidia pre: vfio-pci
      options vfio-pci disable_denylist=1 ids=${lib.concatStringsSep ":" vfioIds}
    ''
    + (lib.concatMapStringsSep "\n" (n: ''
      blacklist ${n}
      install ${n} ${pkgs.coreutils}/bin/true
    '') blacklistedModules);
}
