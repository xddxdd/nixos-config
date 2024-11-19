{
  pkgs,
  lib,
  config,
  ...
}:
let
  steam-offload = lib.hiPrio (
    pkgs.runCommand "steam-override" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${config.programs.steam.package}/bin/steam $out/bin/steam \
        --set __NV_PRIME_RENDER_OFFLOAD 1 \
        --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
        --set __GLX_VENDOR_LIBRARY_NAME nvidia \
        --set __VK_LAYER_NV_optimus NVIDIA_only
    ''
  );
in
{
  environment.systemPackages = (lib.optionals config.programs.steam.enable [ steam-offload ]) ++ [
    pkgs.nvtopPackages.full
  ];

  # Enable CUDA
  hardware.graphics.enable = true;

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  # nvidia-settings doesn't work with clang lto
  hardware.nvidia.nvidiaSettings = false;

  virtualisation.docker.enableNvidia = true;
  hardware.nvidia-container-toolkit.enable = true;

  systemd.services.nvidia-persistenced.unitConfig.ConditionPathExists = "/dev/nvidia0";
}
