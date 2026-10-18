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
    }
  ) config.services.redis.servers;

  lantian.harden = lib.mapAttrs' (
    k: v: lib.nameValuePair "redis-${k}" true
  ) config.services.redis.servers;
}
