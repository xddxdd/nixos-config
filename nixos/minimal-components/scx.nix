{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  services.scx = {
    # Broken on aarch64
    # Only enable on client, uncertain improvements on server
    enable = pkgs.stdenv.hostPlatform.isx86_64 && LT.this.hasTag LT.tags.client;
    scheduler = "scx_flash";
    extraArgs =
      if LT.this.hasTag LT.tags.client then
        [
          "-m"
          "all"
        ]
      else
        [
          "-m"
          "performance"
        ];
  };

  lantian.preservation.directories = [ "/root/.cache/pandemonium" ];

  systemd.services.scx = {
    inherit (config.services.scx) enable;
    serviceConfig = lib.mkIf config.services.scx.enable (
      LT.realtime
      // LT.serviceHarden
      // {
        Restart = lib.mkForce "always";
        RestartSec = "3";
        # scx loads BPF schedulers and needs realtime scheduling privileges;
        # proc/capability isolation and syscall filters would block it
        AmbientCapabilities = [
          "CAP_SYS_ADMIN"
          "CAP_BPF"
          "CAP_PERFMON"
          "CAP_SYS_NICE"
        ];
        CapabilityBoundingSet = [
          "CAP_SYS_ADMIN"
          "CAP_BPF"
          "CAP_PERFMON"
          "CAP_SYS_NICE"
        ];
        PrivateDevices = false;
        ProtectProc = "default";
        ProcSubset = "all";
        SystemCallFilter = [ ];
      }
    );
  };
}
