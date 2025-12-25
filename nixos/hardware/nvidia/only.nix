{ pkgs, config, ... }:
{
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.powerManagement.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidia_x11_beta;
  hardware.nvidia.open = false;
  hardware.nvidia.videoAcceleration = true;

  # nvidia-settings doesn't work with clang lto
  hardware.nvidia.nvidiaSettings = false;

  # Enable CUDA
  hardware.graphics.enable = true;

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";

    # For hwdec to work on firefox
    NVD_BACKEND = "direct";
  };

  environment.systemPackages = [
    pkgs.nvtopPackages.full
  ];

  programs.firefox.preferences = {
    "widget.dmabuf.force-enabled" = true;
  };

  virtualisation.docker.enableNvidia = true;
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;
}
