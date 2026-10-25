{
  lib,
  config,
  ...
}:
{
  lantian.harden = lib.mapAttrs' (
    k: _: lib.nameValuePair ("redis" + lib.optionalString (k != "") "-${k}") { enable = true; }
  ) config.services.redis.servers;
}
