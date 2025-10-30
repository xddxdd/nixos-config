{
  config,
  lib,
  LT,
  ...
}:
{
  assertions = lib.flatten (
    lib.mapAttrsToList (n: v: [
      {
        assertion = lib.hasSuffix ".localhost" n -> v.accessibleBy == "localhost";
        message = "${n}'s accessibleBy is not set to localhost";
      }
      {
        assertion =
          builtins.elem n LT.constants.publicSites
          || v.accessibleBy != "public"
          || v.locations."/".enableOAuth or false
          || v.locations."/".enableBasicAuth or false;
        message = "${n} is publicly accessible without authentication";
      }
    ]) config.lantian.nginxVhosts
  );
}
