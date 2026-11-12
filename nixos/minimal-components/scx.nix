{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  services.scx-loader = {
    # Broken on aarch64
    # Only enable on client, uncertain improvements on server
    enable = pkgs.stdenv.hostPlatform.isx86_64 && LT.this.hasTag LT.tags.client;
    config = {
      default_sched = "scx_flash";
      default_mode = "Gaming";
      scheds = {
        scx_flash = {
          gaming_mode = [
            "-m"
            "all"
          ];
          lowlatency_mode = [
            "-m"
            "performance"
          ];
        };
        scx_lavd = {
          gaming_mode = [
            "--performance"
            "--pinned-slice-us"
            "500"
          ];
          lowlatency_mode = [
            "--performance"
            "--pinned-slice-us"
            "500"
          ];
        };
        scx_bpfland = {
          gaming_mode = [
            "-m"
            "all"
          ];
          lowlatency_mode = [
            "-m"
            "performance"
            "-w"
          ];
        };
        # No mode flags upstream; runs with its own defaults
        scx_pandemonium = { };
      };
    };
  };

  lantian.preservation.directories = [ "/root/.cache/pandemonium" ];

  lantian.harden.scx_loader = lib.mkIf config.services.scx-loader.enable {
    enable = true;
    realtime = true;
    enableConfinement = false;
  };

  systemd.services.scx_loader = lib.mkIf config.services.scx-loader.enable {
    serviceConfig = {
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
    };
  };
}
