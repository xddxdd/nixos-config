{
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.firewall.presets.ltnet-fallback-snat.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "SNAT traffic to ltnet addresses (198.18.0.200-255) reserved for devices without BGP sessions.";
  };

  config = lib.mkIf config.lantian.firewall.presets.ltnet-fallback-snat.enable {
    lantian.firewall.chains.NAT_POSTROUTING.rules = [
      {
        priority = LT.firewallPriorities.service;
        text = ''
          ip daddr 198.18.0.200-198.18.0.255 snat to ${LT.this.ltnet.IPv4}
          ip6 daddr fdbc:f9dc:67ad::200-fdbc:f9dc:67ad::255 snat to ${LT.this.ltnet.IPv6}
        '';
      }
    ];
  };
}
