{ config, ... }:
{
  boot.kernelParams = [ "gpu_unlock.targets=0000:81:00.0" ];

  # The unlock must finish before the NVIDIA driver binds the GPU.
  boot.initrd.kernelModules = [ "gpu_unlock" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.gpu-unlock ];
  hardware.firmware = [ config.boot.kernelPackages.gpu-unlock.firmware ];
}
