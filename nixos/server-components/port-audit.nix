{ config, ... }:
{
  systemd.services.port-audit = {
    description = "Audit listening ports against the firewall allowlists";

    serviceConfig = {
      Type = "oneshot";
      # The wrapper from nixos/minimal-components/port-audit.nix injects the
      # eval-time allowlists and reserved CIDRs.
      ExecStart = "${config.system.path}/bin/port-audit";
      # port-audit reads /proc/net/* and /proc/sys/net/ipv4/ip_local_port_range;
      # the hardening preset's pid-only proc subset hides both.
      ProcSubset = "all";
      ProtectProc = "default";
    };

    unitConfig.OnFailure = "notify-email@%n.service";
  };

  lantian.harden.port-audit = {
    enable = true;
    enableConfinement = false;
  };

  systemd.timers.port-audit = {
    wantedBy = [ "timers.target" ];
    partOf = [ "port-audit.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "10min";
      Unit = "port-audit.service";
    };
  };
}
