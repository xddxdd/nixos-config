{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
}@args:
let
  dnsconfigJs =
    let
      registrarVars = builtins.map (n: "var REG_${n} = NewRegistrar('${n}');") (
        [ "none" ] ++ config.registrars
      );
      providerVars = builtins.map (n: "var DNS_${n} = NewDnsProvider('${n}');") (
        [ "none" ] ++ config.providers
      );
      domainVars = builtins.map (v: v._dnsconfig_js) (
        builtins.sort (a: b: a.domain < b.domain) (lib.flatten config.domains)
      );
    in
    builtins.concatStringsSep "\n" (registrarVars ++ providerVars ++ domainVars);
in
{
  options = {
    _dnsconfig_js = lib.mkOption {
      readOnly = true;
      default = dnsconfigJs;
    };
  };
}
