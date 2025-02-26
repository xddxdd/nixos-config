{ pkgs, lib, ... }:
{
  boot.kernelModules = [ "vfio-pci" ];
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "amd_iommu=on"
    "isolcpus=120-127"
  ];
  boot.extraModprobeConfig =
    let
      vfioIds = [
        "10de:2204" # NVIDIA RTX 3090
      ];
      blacklistedModules = [
        "nouveau"
        "nvidiafb"
        "nvidia"
        "nvidia-uvm"
        "nvidia-drm"
        "nvidia-modeset"
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
