{ pkgs, ... }:
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

    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
    };
  };
}
