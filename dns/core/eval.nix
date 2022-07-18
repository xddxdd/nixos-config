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
    , records
    }:
    let
      providerCommands = builtins.concatStringsSep ", " (builtins.map (n: "DnsProvider(DNS_${n})") providers);
      formattedDomain = "${if reverse then "REV(" else ""}${formatArg domain}${if reverse then ")" else ""}";
    in
    [
      ("D(${formattedDomain}, REG_${registrar}, ${providerCommands}, DefaultTTL(${formatArg defaultTTL}), NAMESERVER_TTL(${formatArg nameserverTTL}));")
    ] ++ (builtins.map (record: "D_EXTEND(${formattedDomain}, ${record});") (lib.flatten records));
  mapDomains = builtins.map mapDomainFunc (lib.flatten domains);

in
builtins.concatStringsSep "\n" (
  (lib.flatten mapRegistrars)
  ++ (lib.flatten mapProviders)
  ++ (builtins.sort (a: b: a < b) (lib.flatten mapDomains))
  ++ [ "" ]
)
