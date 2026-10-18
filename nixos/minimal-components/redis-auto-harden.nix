{
  lib,
  LT,
  config,
  ...
}:
{
  systemd.services = lib.mapAttrs' (
    k: v:
    lib.nameValuePair "redis-${k}" {
      serviceConfig = LT.serviceHarden;
      confinement = {
        enable = true;
        fullUnit = true;
      };
    }
  ) config.services.redis.servers;
}
