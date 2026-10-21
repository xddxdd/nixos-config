{
  config,
  pkgs,
  lib,
  LT,
  ...
}:
let
  hardenArgs = (import ../../helpers/fn/service-harden.nix { inherit lib; }).serviceHardenArgs;
  emailNotificationScript = pkgs.writeShellScript "email.sh" ''
    MAILTO="lantian@lantian.pub"

    exec sendmail -t <<EOF
    To: $MAILTO
    Subject: $HOSTNAME UPS status: $*

    $HOSTNAME UPS status: $*
    EOF
  '';

  upsmonNotifyTypes = {
    ONLINE = "UPS is back online";
    ONBATT = "UPS is on battery";
    LOWBATT = "UPS is on battery and has a low battery (is critical)";
    FSD = "UPS is being shutdown by the primary";
    COMMOK = "Communications established with the UPS";
    COMMBAD = "Communications lost to the UPS";
    SHUTDOWN = "The system is being shutdown";
    REPLBATT = "The UPS battery is bad and needs to be replaced";
    NOCOMM = "A UPS is unavailable (cannot be contacted for monitoring)";
    NOPARENT = "upsmon parent process died - shutdown impossible";
    CAL = "UPS calibration in progress";
    NOTCAL = "UPS calibration finished";
    OFF = "UPS administratively OFF or asleep";
    NOTOFF = "UPS no longer administratively OFF or asleep";
    BYPASS = "UPS on bypass (powered, not protecting)";
    NOTBYPASS = "UPS no longer on bypass";
    SUSPEND_STARTING = "OS is entering sleep/suspend/hibernate mode";
    SUSPEND_FINISHED = "OS just finished sleep/suspend/hibernate mode, de-activating obsolete UPS readings to avoid an unfortunate shutdown";
  };
in
{
  lantian.secrets.nut-pass = {
    owner = "root";
    group = config.services.prometheus.exporters.nut.group;
    mode = "0440";
  };
  power.ups = {
    enable = true;
    mode = "netserver";
    ups.ups = {
      driver = "usbhid-ups";
      port = "auto";
      shutdownOrder = -1;
    };
    users.root = {
      upsmon = "primary";
      passwordFile = config.lantian.secrets.nut-pass.path;
      instcmds = [ "ALL" ];
      actions = [
        "SET"
        "FSD"
      ];
    };

    upsmon.monitor.ups = {
      user = "root";
      type = "primary";
      system = "ups@localhost";
      passwordFile = config.lantian.secrets.nut-pass.path;
      powerValue = 1;
    };

    upsmon.settings = {
      MINSUPPLIES = 1;
      RUN_AS_USER = "root";
      NOCOMMWARNTIME = 3600;
      NOTIFYCMD = builtins.toString emailNotificationScript;
      POWERDOWNFLAG = "/run/nut/killpower";

      NOTIFYMSG = lib.mapAttrsToList (k: v: [
        k
        v
      ]) upsmonNotifyTypes;

      NOTIFYFLAG = lib.mapAttrsToList (k: v: [
        k
        "EXEC"
      ]) upsmonNotifyTypes;
    };
  };

  services.dbus.enable = true;
  services.prometheus.exporters.nut = {
    enable = true;
    listenAddress = LT.this.ltnet.IPv4;
    port = LT.port.Prometheus.NUTExporter;
    nutUser = "root";
    passwordPath = config.lantian.secrets.nut-pass.path;
  };

  systemd.services.upsd = lib.mkIf config.power.ups.enable {
    # Upstream orders upsd after upsmon; use daemon-before-monitor instead.
    after = lib.mkForce [
      "network.target"
      "lantian-secrets.service"
    ];
    requires = [ "lantian-secrets.service" ];
    environment.NUT_CONFPATH = lib.mkForce "/run/nut";
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = 5;
      PrivateUsers = false;
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_SETUID"
        "CAP_SETGID"
      ];
      # NUT drops identities; its credential installer changes file ownership.
      SystemCallFilter = hardenArgs.SystemCallFilter ++ [
        "@chown"
        "@setuid"
      ];
      BindPaths = [
        "/run/nut"
        "/var/lib/nut"
        "/var/state/ups"
      ];
      BindReadOnlyPaths = [
        "${config.environment.etc."nut/nut.conf".source}:/run/nut/nut.conf"
        "${config.environment.etc."nut/ups.conf".source}:/run/nut/ups.conf"
        "${config.environment.etc."nut/upsd.conf".source}:/run/nut/upsd.conf"
        "/run/systemd/journal/dev-log:/dev/log"
        "/etc/passwd"
        "/etc/group"
      ];
    };
  };
  sops.secrets.smtp-pass.restartUnits = lib.mkIf config.power.ups.upsmon.enable [ "upsmon.service" ];

  systemd.services.upsmon = lib.mkIf config.power.ups.upsmon.enable {
    after = [
      "lantian-secrets.service"
      "upsd.service"
      "upsdrv.service"
      "dbus.socket"
    ];
    requires = [
      "lantian-secrets.service"
      "upsd.service"
      "upsdrv.service"
      "dbus.socket"
    ];
    partOf = [ "upsd.service" ];
    path = [ pkgs.msmtp ];
    environment = {
      NUT_CONFPATH = lib.mkForce "/run/nut";
      NUT_PIDPATH = "/run/nut";
    };
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = 5;
      PrivateUsers = false;
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_FOWNER"
        "CAP_DAC_OVERRIDE"
        "CAP_SETUID"
        "CAP_SETGID"
      ];
      SystemCallFilter = hardenArgs.SystemCallFilter ++ [
        "@chown"
        "@setuid"
      ];
      BindPaths = [
        "/run/nut"
        "/var/lib/nut"
        "/var/state/ups"
      ];
      BindReadOnlyPaths = [
        "${config.environment.etc."nut/nut.conf".source}:/run/nut/nut.conf"
        "/run/systemd/journal/dev-log:/dev/log"
        "/etc/passwd"
        "/etc/group"
        "/run/systemd/private"
        "/run/dbus/system_bus_socket"
        "${config.environment.etc.msmtprc.source}:/etc/msmtprc"
        config.sops.secrets.smtp-pass.path
      ];
    };
  };

  systemd.services.prometheus-nut-exporter = {
    after = [
      "lantian-secrets.service"
      "upsd.service"
    ];
    requires = [
      "lantian-secrets.service"
      "upsd.service"
    ];
    partOf = [ "upsd.service" ];
    serviceConfig = LT.serviceHarden // {
      DynamicUser = lib.mkForce false;
      RestartSec = "5s";
      BindReadOnlyPaths = [ config.lantian.secrets.nut-pass.path ];
    };
  };
  users.users.nut-exporter = {
    group = "nut-exporter";
    isSystemUser = true;
  };
  users.groups.nut-exporter = { };

  # Keep the shared runtime directory stable across daemon/monitor restarts.
  systemd.tmpfiles.rules = [ "d /run/nut 0755 root root - -" ];
  lantian.harden.upsd = true;
  lantian.harden.upsmon = true;
  lantian.harden.prometheus-nut-exporter = true;

}
