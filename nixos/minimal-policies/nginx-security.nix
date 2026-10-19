{
  config,
  lib,
  LT,
  ...
}:
{
  assertions = lib.flatten (
    (lib.mapAttrsToList (n: v: [
      {
        assertion = lib.hasSuffix ".localhost" n -> v.accessibleBy == "localhost";
        message = "${n}'s accessibleBy is not set to localhost";
      }
      {
        assertion = builtins.elem n LT.constants.publicSites || v.accessibleBy != "public";
        message = "${n} is publicly accessible";
      }
    ]) (config.lantian.nginxVhosts or { }))
    ++ (lib.mapAttrsToList (n: v: [
      {
        # Prevent lt-hp-omen from exposing to private LAN
        assertion =
          (!builtins.elem config.networking.hostName [ "lt-hp-omen" ])
          || builtins.elem n [
            "pi"
            "lab"
            "llama-swap"
          ];
        message = "${n} is LAN accessible";
      }
    ]) (config.lantian.localVhosts or { }))
  );
}
