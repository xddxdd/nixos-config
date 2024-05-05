{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

  steam-offload = lib.hiPrio (
    pkgs.runCommand "steam-override" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.steam}/bin/steam $out/bin/steam \
        --set __NV_PRIME_RENDER_OFFLOAD 1 \
        --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
        --set __GLX_VENDOR_LIBRARY_NAME nvidia \
        --set __VK_LAYER_NV_optimus NVIDIA_only
    ''
  );
in
{
  environment.systemPackages = [
    nvidia-offload
  ] ++ lib.optionals config.programs.steam.enable [ steam-offload ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # nvidia-settings doesn't work with clang lto
  hardware.nvidia.nvidiaSettings = false;

  virtualisation.docker.enableNvidia = true;
  hardware.nvidia-container-toolkit.enable = true;
}
