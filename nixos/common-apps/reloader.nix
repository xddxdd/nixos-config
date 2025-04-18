{ lib, config, ... }:
{
  systemd.services.reloader = {
    serviceConfig.Type = "oneshot";
    script =
      ''
        echo "Reloading..."
      ''
      + (lib.optionalString config.services.bird.enable ''
        systemctl reload bird.service || true
      '')
      + (lib.optionalString config.services.knot.enable ''
        systemctl reload knot.service || true
      '')
      + (lib.optionalString config.services.pdns-recursor.enable ''
        systemctl reload pdns-recursor.service || true
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
