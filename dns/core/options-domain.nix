{ config, lib, ... }@args:
let
  parentConfig = config;
in
{ config, ... }:
{
  options = {
    domain = lib.mkOption { type = lib.types.str; };
    reverse = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    registrar = lib.mkOption {
      type = lib.types.str;
      default = "none";
    };
    providers = lib.mkOption { type = lib.types.listOf lib.types.str; };
    dnssec = lib.mkOption {
      type = lib.types.enum [
        null
        true
        false
      ];
      default = null;
    };
    defaultTTL = lib.mkOption {
      type = lib.types.str;
      default = "1h";
    };
    nameserverTTL = lib.mkOption {
      type = lib.types.str;
      default = "1h";
    };
    enableWildcard = lib.mkOption {
      type = lib.types.bool;
      default = !(!config.reverse && builtins.elem "henet" config.providers);
    };
    records = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule (import ./options-record.nix args));
    };

    _dnsconfig_js = lib.mkOption {
      type = lib.types.str;
      default = "Generated below";
    };
  };

  config._dnsconfig_js =
    let
      formatArg = s: if (builtins.isString s) then (lib.escapeShellArg s) else (builtins.toString s);

      providerCommands = lib.concatMapStringsSep ", " (n: "DnsProvider(DNS_${n})") config.providers;
      formattedDomain = "${if config.reverse then "REV(" else ""}${formatArg config.domain}${
        if config.reverse then ")" else ""
      }";

      recordStrings = lib.flatten (
        builtins.map (v: parentConfig.recordHandlers."${v.recordType}" v) config.records
      );

      filteredRecordStrings =
        if config.enableWildcard then
          recordStrings
        else
          builtins.filter (v: !((lib.hasInfix ''("*'' v) || (lib.hasInfix ''('*'' v))) recordStrings;
    in
    builtins.concatStringsSep "\n" (
      [
        "D(${formattedDomain}, REG_${config.registrar}, ${providerCommands}, DefaultTTL(${formatArg config.defaultTTL}), NAMESERVER_TTL(${formatArg config.nameserverTTL}));"
      ]
      ++ (lib.optional (
        config.dnssec != null && config.dnssec
      ) "D_EXTEND(${formattedDomain}, AUTODNSSEC_ON);")
      ++ (lib.optional (
        config.dnssec != null && !config.dnssec
      ) "D_EXTEND(${formattedDomain}, AUTODNSSEC_OFF);")
      ++ (builtins.map (record: "D_EXTEND(${formattedDomain}, ${record});") filteredRecordStrings)
      ++ [ "" ]
    );
}
