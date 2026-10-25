{ serviceHardenArgs, LT, ... }:
{
  systemd.services."prometheus-node-exporter".serviceConfig = {
    RestartSec = "5s";
    # Collects host-wide /proc and /sys metrics; MountAPIVFS (via confinement)
    # mounts the real host procfs/sysfs inside the chroot
    ProcSubset = "all";
    ProtectProc = "default";
    # Modes=0 reads clock state; setting it still requires the absent CAP_SYS_TIME.
    SystemCallFilter = serviceHardenArgs.SystemCallFilter ++ [ "adjtimex" ];
    BindReadOnlyPaths = [
      # The collector uses the system bus's /var/run path, absent in the chroot.
      "/run/dbus:/var/run/dbus"
      # Device metadata is not available on every host.
      "-/run/udev/data"
    ];
  };

  lantian.harden."prometheus-node-exporter" = {
    enable = true;
    etc."os-release" = true;
  };

  services.prometheus.exporters = {
    node = {
      enable = !(LT.this.hasTag LT.tags.client);
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
    };
  };
}
