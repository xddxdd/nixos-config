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
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidia_x11_vgpu_16_12;
  hardware.nvidia.open = false;

  boot.kernelModules = [
    "nvidia"
    "nvidia_vgpu_vfio"
  ];

  environment.etc."vgpu_unlock/profile_override.toml".text = ''
    [profile.nvidia-51]
    cuda_enabled = 1
    frl_enabled = 0
  '';

  systemd.services."nvidia-persistenced".enable = lib.mkForce false;

  systemd.services."nvidia-vgpud" = {
    description = "NVIDIA vGPU Daemon";
    wants = [ "syslog.target" ];
    after = [ "systemd-modules-load.service" ];
    requires = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      LD_PRELOAD = "${pkgs.nur-xddxdd.vgpu-unlock-rs}/lib/libvgpu_unlock_rs.so";
    };

    serviceConfig = {
      Type = "forking";
      Restart = "no";
      ExecStart = "-${nvidia_x11.bin}/bin/nvidia-vgpud --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-vgpud";
    };
  };

  systemd.services."nvidia-vgpu-mgr" = {
    description = "NVIDIA vGPU Manager Daemon";
    wants = [ "syslog.target" ];
    after = [ "systemd-modules-load.service" ];
    requires = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      LD_PRELOAD = "${pkgs.nur-xddxdd.vgpu-unlock-rs}/lib/libvgpu_unlock_rs.so";
    };

    postStart = ''
      set -euo pipefail
      ls -1 /sys/class/mdev_bus/*/mdev_supported_types | grep "^nvidia"
    '';

    serviceConfig = {
      Type = "forking";
      Restart = "always";
      KillMode = "process";
      ExecStart = "${nvidia_x11.bin}/bin/nvidia-vgpu-mgr --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-vgpu-mgr";
    };
  };

  systemd.tmpfiles.settings = {
    vgpu-config = {
      "/usr/share/nvidia/vgpu/vgpuConfig.xml"."L" = {
        argument = "${nvidia_x11.bin}/share/nvidia/vgpu/vgpuConfig.xml";
      };
    };
  };
}
