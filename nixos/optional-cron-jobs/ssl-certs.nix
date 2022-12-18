{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  systemd.services.ssl-certs = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ReadWritePaths = [ "/nix/persistent/sync-servers/acme.sh" ];
    };
    unitConfig.OnFailure = "notify-email@%n.service";
    script = ''
      exec ${pkgs.acme-sh}/bin/acme.sh \
        --config-home /nix/persistent/sync-servers/acme.sh \
        --auto-upgrade 0 \
        --cron
    '';
  };

  systemd.timers.ssl-certs = {
    wantedBy = [ "timers.target" ];
    partOf = [ "ssl-certs.service" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Unit = "ssl-certs.service";
    };
  };
}
