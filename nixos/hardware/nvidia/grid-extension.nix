{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
let
  netns = config.lantian.netns.nvidia-gridd;
  nvidia_x11 = config.hardware.nvidia.package;
in
{
  # nvidia-gridd will fail if there are too many interfaces on host
  lantian.netns.nvidia-gridd = {
    ipSuffix = "65";
  };

  preservation.preserveAt."/nix/persistent" = {
    directories = builtins.map LT.preservation.mkFolder [ "/etc/nvidia/ClientConfigToken" ];
  };

  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidia_x11_grid_16_12;
  hardware.nvidia.open = false;

  systemd.services."nvidia-gridd" = netns.bind {
    description = "NVIDIA Grid Daemon";
    wants = [
      "syslog.target"
      "network-online.target"
    ];
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p /var/lib/nvidia/GridLicensing";
      ExecStart = "${lib.getExe' nvidia_x11.bin "nvidia-gridd"} --verbose";
      ExecStopPost = "${lib.getExe' pkgs.coreutils "rm"} -rf /var/run/nvidia-gridd";
    };
  };
}
