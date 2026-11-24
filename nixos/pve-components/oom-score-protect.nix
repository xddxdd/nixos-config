{ lib, pkgs, ... }:
{
  lantian.harden.oom-score-protect = {
    enable = true;
    enableTripwire = true;
  };
  systemd.services.oom-score-protect = {
    after = [ "pve-cluster.service" ];
    wants = [ "pve-cluster.service" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      while true; do
        for PID in $(${lib.getExe' pkgs.procps "pgrep"} -f "bin/qemu-kvm|bin/virtiofsd|^vgpu"); do
          echo -1000 > "/proc/$PID/oom_score_adj" 2>/dev/null
        done
        ${lib.getExe' pkgs.coreutils "sleep"} 10
      done
    '';

    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
      # Adjusts oom_score_adj of host-side QEMU processes
      AmbientCapabilities = [ "CAP_SYS_RESOURCE" ];
      CapabilityBoundingSet = [ "CAP_SYS_RESOURCE" ];
      ProtectProc = "default";
      ProcSubset = "all";
      SystemCallFilter = [ ];
      # Needs host capabilities and full host /proc view (sees QEMU PIDs),
      # which a confinement chroot cannot provide
      PrivateUsers = false;
    };
  };
}
