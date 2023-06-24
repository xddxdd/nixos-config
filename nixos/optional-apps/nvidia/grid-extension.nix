{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.nvidia-gridd;
  nvidia_x11 = config.hardware.nvidia.package;
in {
  # nvidia-gridd will fail if there are too many interfaces on host
  lantian.netns.nvidia-gridd = {
    ipSuffix = "65";
  };

  environment.persistence."/nix/persistent" = {
    directories = [
      "/etc/nvidia/ClientConfigToken"
    ];
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidia_x11_grid_14_4;

  systemd.services."nvidia-gridd" = netns.bind {
    description = "NVIDIA Grid Daemon";
    wants = ["syslog.target" "network-online.target"];
    after = ["network-online.target" "nss-lookup.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/nvidia/GridLicensing";
      ExecStart = "${nvidia_x11.bin}/bin/nvidia-gridd --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-gridd";
    };
  };
}
