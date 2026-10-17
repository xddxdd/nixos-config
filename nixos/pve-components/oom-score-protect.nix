{ pkgs, LT, ... }:
{
  systemd.services.oom-score-protect = {
    after = [ "pve-cluster.service" ];
    wants = [ "pve-cluster.service" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ procps ];

    script = ''
      while true; do
        for PID in $(pgrep -f "bin/qemu-kvm|bin/virtiofsd|^vgpu"); do
          echo -1000 > "/proc/$PID/oom_score_adj" 2>/dev/null
        done
        sleep 10
      done
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      # Adjusts oom_score_adj of host-side QEMU processes
      AmbientCapabilities = [ "CAP_SYS_RESOURCE" ];
      CapabilityBoundingSet = [ "CAP_SYS_RESOURCE" ];
      ProtectProc = "default";
      ProcSubset = "all";
      SystemCallFilter = [ ];
    };
  };
}
