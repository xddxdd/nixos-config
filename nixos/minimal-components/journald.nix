{ config, pkgs, ... }:
{
  services.journald.settings.Journal = {
    ForwardToConsole = false;
    ForwardToKMsg = false;
    ForwardToWall = false;
    Storage = "persistent";
    SystemMaxFileSize = "100M";
    SystemMaxUse = "1G";
  };

  # Masking the audit socket leaves an already-running journald holding its
  # inherited netlink FD. Restart it when that route changes, without losing
  # the regular journal or excluding audit events from auditd's own trail.
  systemd.services.systemd-journald.restartTriggers = [
    (pkgs.writeText "journald-audit-route" (
      if config.systemd.sockets.systemd-journald-audit.enable then "enabled" else "disabled"
    ))
  ];
}
