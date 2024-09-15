{ pkgs, lib, ... }:
{
  boot.kernelModules = [ "vfio-pci" ];
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "amd_iommu=on"
    "isolcpus=24-31,56-63"
  ];
  boot.extraModprobeConfig =
    let
      vfioIds = [
        # "8086:19e3" # Intel QAT C3xxxx VF
      ];
      blacklistedModules = [
        # "qat_c3xxxvf" # Intel QAT C3xxxx VF
      ];
    in
    ''
      options vfio-pci disable_denylist=1 ids=${lib.concatStringsSep ":" vfioIds}
    ''
    + (lib.concatMapStringsSep "\n" (n: ''
      blacklist ${n}
      install ${n} ${pkgs.coreutils}/bin/true
    '') blacklistedModules);
}
