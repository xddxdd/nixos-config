{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");

  emailNotificationScript = pkgs.writeShellScript "email.sh" ''
    MAILTO="${glauthUsers.lantian.mail}"

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
    NOCOMM = "A UPS is unavailable (can’t be contacted for monitoring)";
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
  age.secrets.nut-pass.file = inputs.secrets + "/nut-pass.age";
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
      passwordFile = config.age.secrets.nut-pass.path;
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
      passwordFile = config.age.secrets.nut-pass.path;
      powerValue = 1;
    };

    upsmon.settings = {
      MINSUPPLIES = 1;
      RUN_AS_USER = "root";
      NOCOMMWARNTIME = 3600;
      NOTIFYCMD = builtins.toString emailNotificationScript;

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

  systemd.services.upsd = lib.mkIf config.power.ups.enable {
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };
  systemd.services.upsmon = lib.mkIf config.power.ups.upsmon.enable {
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };
}
