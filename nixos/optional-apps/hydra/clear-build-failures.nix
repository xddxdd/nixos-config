{
  config,
  LT,
  ...
}:
{
  systemd.services.hydra-clear-build-failures = {
    path = [ config.services.postgresql.package ];
    script = ''
      echo "TRUNCATE hydra.public.failedpaths" | psql
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      User = "hydra";
      Group = "hydra";
    };
  };

  systemd.timers.hydra-clear-build-failures = {
    wantedBy = [ "timers.target" ];
    partOf = [ "hydra-clear-build-failures.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "12h";
      Unit = "hydra-clear-build-failures.service";
    };
  };
}
