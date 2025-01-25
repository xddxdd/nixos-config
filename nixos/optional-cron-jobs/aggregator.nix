{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
let
  py = pkgs.python3.withPackages (
    ps: with ps; [
      geoip2
      pyyaml
      requests
      tqdm
    ]
  );
in
{
  age.secrets.aggregator-env.file = inputs.secrets + "/aggregator-env.age";

  systemd.services.aggregator = {
    environment = {
      TZ = "Asia/Shanghai";
    };
    script = ''
      cp -r ${LT.sources.aggregator.src}/* .
      chmod -R 755 *
      exec ${py}/bin/python3 -u subscribe/collect.py --all --overwrite --skip
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.aggregator-env.path;
      CacheDirectory = "aggregator";
      WorkingDirectory = "/var/cache/aggregator";
    };
  };

  systemd.timers.aggregator = {
    wantedBy = [ "timers.target" ];
    partOf = [ "aggregator.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "aggregator.service";
    };
  };
}
