{ pkgs, config, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      ovmf.enable = true;
      swtpm.enable = true;
    };
  };

  users.users.lantian.extraGroups = [ "libvirtd" ];

  boot.kernelParams =
    (pkgs.lib.optionals config.hardware.cpu.intel.updateMicrocode [ "intel_iommu=on" "iommu=pt" ])
    ++ (pkgs.lib.optionals config.hardware.cpu.amd.updateMicrocode [ "amd_iommu=on" ]);
}
