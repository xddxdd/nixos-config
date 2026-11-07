{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.firewall.presets.kms-redirect;
in
{
  options.lantian.firewall.presets.kms-redirect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Redirect KMS requests to the ltnet KMS server.";
    };
    targetIPv4 = lib.mkOption {
      type = lib.types.str;
      default = "198.19.0.252";
      description = "KMS server IPv4 address.";
    };
    targetIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "fdbc:f9dc:67ad:2547::1688";
      description = "KMS server IPv6 address.";
    };
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "@ZONE_LAN_INTERFACES"
        "@ZONE_LTNET_INTERFACES"
      ];
      description = "Interface match expressions the redirect applies to.";
    };
  };

  config = lib.mkIf cfg.enable {
    lantian.firewall.chains.NAT_PREROUTING.dnat = [
      {
        priority = LT.firewallPriorities.service;
        matches = map (i: "tcp dport ${LT.portStr.KMS} iifname ${i}") cfg.lanInterfaces;
        ipv4 = "${cfg.targetIPv4}:${LT.portStr.KMS}";
        ipv6 = "[${cfg.targetIPv6}]:${LT.portStr.KMS}";
      }
    ];
    lantian.firewall.chains.NAT_OUTPUT.dnat = [
      {
        priority = LT.firewallPriorities.early;
        matches = [ "tcp dport ${LT.portStr.KMS}" ];
        ipv4 = "${cfg.targetIPv4}:${LT.portStr.KMS}";
        ipv6 = "[${cfg.targetIPv6}]:${LT.portStr.KMS}";
      }
    ];
  };
}
