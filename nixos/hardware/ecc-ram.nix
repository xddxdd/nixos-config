{ LT, ... }:
{
  hardware.rasdaemon.enable = true;

  services.prometheus.exporters.rasdaemon = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.RasdaemonExporter;
  };

  systemd.services.rasdaemon.serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    # rasdaemon reads /proc/{mounts,cpuinfo}, EDAC/mce state, mounts
    # debugfs/tracefs itself and writes tracepoint filters
    PrivateDevices = false;
    ProtectKernelTunables = false;
    ProtectProc = "default";
    ProcSubset = "all";
    AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
    CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
    SystemCallFilter = [ ];
    # chroot's tmpfs root is ephemeral; bind host state dir through
    PrivateUsers = false;
    BindPaths = [ "/var/lib/rasdaemon" ];
  };
  systemd.services.rasdaemon.confinement = { enable = true; fullUnit = true; };
  systemd.services."prometheus-rasdaemon-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    # Reads rasdaemon's host-wide event files
    ProcSubset = "all";
    ProtectProc = "default";
    BindReadOnlyPaths = [ "/var/lib/rasdaemon" ];
  };
  systemd.services."prometheus-rasdaemon-exporter".confinement = { enable = true; fullUnit = true; };
}
