{ config, lib, ... }:
{
  assertions = lib.flatten (
    lib.mapAttrsToList (n: v: [
      {
        assertion = lib.hasSuffix ".localhost" n -> v.accessibleBy == "localhost";
        message = "${n}'s accessibleBy is not set to localhost";
      }
    ]) config.lantian.nginxVhosts
  );
}
