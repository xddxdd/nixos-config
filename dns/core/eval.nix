{ pkgs, lib, ... }:

{ registrars ? { }
, providers ? { }
, domains ? { }
,
}:
let
  formatArg = s: if (builtins.isString s) then (lib.escapeShellArg s) else (builtins.toString s);

  mapRegistrarFunc = n: "var REG_${n} = NewRegistrar('${n}');";
  mapRegistrars = [
    (mapRegistrarFunc "none")
  ] ++ builtins.map mapRegistrarFunc registrars;

  mapProviderFunc = n: "var DNS_${n} = NewDnsProvider('${n}');";
  mapProviders = builtins.map mapProviderFunc providers;

  mapDomainFunc =
    { domain
    , reverse ? false
    , registrar ? "none"
    , providers
    , defaultTTL ? "1d"
    , nameserverTTL ? "1d"
      # HENET disables wildcard for normal domains (not reverse ones) by default
    , enableWildcard ? !(!reverse && builtins.elem "henet" providers)
    , records
    }:
    let
      providerCommands = lib.concatMapStringsSep ", " (n: "DnsProvider(DNS_${n})") providers;
      formattedDomain = "${if reverse then "REV(" else ""}${formatArg domain}${if reverse then ")" else ""}";

      filteredRecords =
        if enableWildcard
        then lib.flatten records
        else
          builtins.filter
            (v: !((lib.hasInfix ''("*'' v) || (lib.hasInfix ''('*'' v)))
            (lib.flatten records);
    in
    [
      "D(${formattedDomain}, REG_${registrar}, ${providerCommands}, DefaultTTL(${formatArg defaultTTL}), NAMESERVER_TTL(${formatArg nameserverTTL}));"
    ] ++ (builtins.map (record: "D_EXTEND(${formattedDomain}, ${record});") filteredRecords);
  mapDomains = builtins.map mapDomainFunc (lib.flatten domains);

in
builtins.concatStringsSep "\n" (
  (lib.flatten mapRegistrars)
  ++ (lib.flatten mapProviders)
  ++ (builtins.sort (a: b: a < b) (lib.flatten mapDomains))
  ++ [ "" ]
)
