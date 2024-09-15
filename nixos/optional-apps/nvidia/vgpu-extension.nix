{
  pkgs,
  lib,
  config,
  ...
}:
let
  nvidia_x11 = config.hardware.nvidia.package;
in
{
  hardware.nvidia.package = config.boot.kernelPackages.nvidia_x11_vgpu_16_5;
  hardware.nvidia.open = false;

  systemd.services."nvidia-persistenced".enable = lib.mkForce false;

  systemd.services."nvidia-vgpud" = {
    description = "NVIDIA vGPU Daemon";
    wants = [ "syslog.target" ];
    after = [ "systemd-modules-load.service" ];
    requires = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      # Restart = "always";
      ExecStart = "${nvidia_x11.bin}/bin/nvidia-vgpud --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-vgpud";
    };
  };

  systemd.services."nvidia-vgpu-mgr" = {
    description = "NVIDIA vGPU Manager Daemon";
    wants = [ "syslog.target" ];
    after = [ "systemd-modules-load.service" ];
    requires = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      # Restart = "always";
      ExecStart = "${nvidia_x11.bin}/bin/nvidia-vgpu-mgr --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-vgpu-mgr";
    };
  };

  systemd.tmpfiles.rules = [
    "L /usr/share/nvidia/vgpu/vgpuConfig.xml - - - - ${nvidia_x11.bin}/share/nvidia/vgpu/vgpuConfig.xml"
  ];
}
