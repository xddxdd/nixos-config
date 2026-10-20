{ lib, LT, ... }:
let
  hardening = import ../../helpers/fn/service-harden.nix { inherit lib; };
in
{
  systemd.services."prometheus-node-exporter".serviceConfig = LT.serviceHarden // {
    RestartSec = "5s";
    # Collects host-wide /proc and /sys metrics; MountAPIVFS (via confinement)
    # mounts the real host procfs/sysfs inside the chroot
    ProcSubset = "all";
    ProtectProc = "default";
    # Modes=0 reads clock state; setting it still requires the absent CAP_SYS_TIME.
    SystemCallFilter = hardening.serviceHardenArgs.SystemCallFilter ++ [ "adjtimex" ];
    BindReadOnlyPaths = [
      # The collector uses the system bus's /var/run path, absent in the chroot.
      "/run/dbus:/var/run/dbus"
      "/etc/os-release"
      # Device metadata is not available on every host.
      "-/run/udev/data"
    ];
  };

  lantian.harden."prometheus-node-exporter" = true;

  services.prometheus.exporters = {
    node = {
      enable = !(LT.this.hasTag LT.tags.client);
      port = LT.port.Prometheus.NodeExporter;
      listenAddress = LT.this.ltnet.IPv4;
      enabledCollectors = [ "systemd" ];
    };
  };
}
