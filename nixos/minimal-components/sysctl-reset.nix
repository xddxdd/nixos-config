{
  config,
  pkgs,
  ...
}:
{
  # Reapply periodically since sysctl values may be reset (e.g. conntrack module reload)
  systemd.services.sysctl-reset = {
    serviceConfig.Type = "oneshot";
    path = [ pkgs.procps ];
    script = "sysctl -w net.nf_conntrack_max=${
      toString config.boot.kernel.sysctl."net.nf_conntrack_max"
    }";
  };

  systemd.timers.sysctl-reset = {
    wantedBy = [ "timers.target" ];
    partOf = [ "sysctl-reset.service" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "sysctl-reset.service";
    };
  };
}
