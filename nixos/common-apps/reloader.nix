{ config, pkgs, ... }:

{
  systemd.services.reloader = {
    serviceConfig.Type = "oneshot";
    script = ''
      echo "Reloading..."
    '' + (pkgs.lib.optionalString config.services.bird2.enable ''
      systemctl reload bird2.service
    '') + (pkgs.lib.optionalString config.services.knot.enable ''
      systemctl reload knot.service
    '') + (pkgs.lib.optionalString config.services.pdns-recursor.enable ''
      systemctl reload pdns-recursor.service
    '');
    unitConfig = {
      After = "network.target";
    };
  };

  systemd.timers.reloader = {
    wantedBy = [ "timers.target" ];
    partOf = [ "reloader.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "reloader.service";
    };
  };
}
