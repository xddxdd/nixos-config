{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.powerManagement.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  # nvidia-settings doesn't work with clang lto
  hardware.nvidia.nvidiaSettings = false;

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
  };

  virtualisation.docker.enableNvidia = true;
  virtualisation.podman.enableNvidia = true;
}
