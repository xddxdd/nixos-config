{ pkgs, ... }:

{ registrars ? { }
, providers ? { }
, domains ? { }
,
}:
let
  formatArg = s: if (builtins.isString s) then (pkgs.lib.escapeShellArg s) else (builtins.toString s);

  mapRegistrarFunc = n: v: "var REG_${n} = NewRegistrar('${n}', '${v}');";
  mapRegistrars = [
    (mapRegistrarFunc "none" "NONE")
  ] ++ pkgs.lib.mapAttrsToList mapRegistrarFunc registrars;

  mapProviderFunc = n: v: "var DNS_${n} = NewDnsProvider('${n}', '${v}');";
  mapProviders = pkgs.lib.mapAttrsToList mapProviderFunc providers;

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
    ] ++ (builtins.map (record: "D_EXTEND(${formattedDomain}, ${record});") (pkgs.lib.flatten records));
  mapDomains = builtins.map mapDomainFunc (pkgs.lib.flatten domains);

in
builtins.concatStringsSep "\n" (
  (pkgs.lib.flatten mapRegistrars)
  ++ (pkgs.lib.flatten mapProviders)
  ++ (builtins.sort (a: b: a < b) (pkgs.lib.flatten mapDomains))
  ++ [ "" ]
)
