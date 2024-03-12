{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.xserver.drivers = [
    {
      name = "modesetting";
      display = true;
      deviceSection = ''
        BusID "PCI:0:2:0"
      '';
    }
  ];

  boot.kernelModules = ["vfio-pci"];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:249d
  '';

  boot.blacklistedKernelModules = ["nouveau" "nvidiafb" "nvidia" "nvidia-uvm" "nvidia-drm" "nvidia-modeset"];
}
