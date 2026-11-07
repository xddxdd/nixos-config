{
  lib,
  LT,
  config,
  ...
}:
let
  cfg = config.lantian.firewall.presets.dn42;
in
{
  options.lantian.firewall.presets.dn42.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "SNAT for LAN clients reaching DN42/NeoNetwork, when this host has DN42/NeoNetwork addresses.";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      lantian.firewall.ipsets = {
        DN42_IPV4 = {
          type = "ipv4_addr";
          flags = [
            "constant"
            "interval"
          ];
          elements = LT.constants.dn42.IPv4;
        };
        DN42_IPV6 = {
          type = "ipv6_addr";
          flags = [
            "constant"
            "interval"
          ];
          elements = LT.constants.dn42.IPv6;
        };
        NEONETWORK_IPV4 = {
          type = "ipv4_addr";
          flags = [
            "constant"
            "interval"
          ];
          elements = LT.constants.neonetwork.IPv4;
        };
        NEONETWORK_IPV6 = {
          type = "ipv6_addr";
          flags = [
            "constant"
            "interval"
          ];
          elements = LT.constants.neonetwork.IPv6;
        };
        LOCAL_IPV4 = {
          type = "ipv4_addr";
          flags = [
            "constant"
            "interval"
          ];
          elements = [ "${LT.this.ltnet.IPv4Prefix}.0/24" ];
        };
        LOCAL_IPV6 = {
          type = "ipv6_addr";
          flags = [
            "constant"
            "interval"
          ];
          elements = [ "${LT.this.ltnet.IPv6Prefix}::/64" ];
        };
      };
    })
    (lib.mkIf (cfg.enable && LT.this.neonetwork.IPv4 != null) {
      lantian.firewall.chains.NAT_POSTROUTING.rules = [
        {
          priority = LT.firewallPriorities.early;
          text = ''
            ip saddr != @DN42_IPV4 ip daddr @NEONETWORK_IPV4 ip daddr != @LOCAL_IPV4 oifname != @ZONE_WAN_INTERFACES snat to ${LT.this.neonetwork.IPv4}
            ip6 saddr != @DN42_IPV6 ip6 daddr @NEONETWORK_IPV6 ip6 daddr != @LOCAL_IPV6 oifname != @ZONE_WAN_INTERFACES snat to ${LT.this.neonetwork.IPv6}
          '';
        }
      ];
    })
    (lib.mkIf (cfg.enable && LT.this.dn42.IPv4 != null) {
      lantian.firewall.chains.NAT_POSTROUTING.rules = [
        {
          priority = LT.firewallPriorities.preService;
          text = ''
            ip saddr != @DN42_IPV4 ip daddr @DN42_IPV4 ip daddr != @NEONETWORK_IPV4 ip daddr != @LOCAL_IPV4 oifname != @ZONE_WAN_INTERFACES snat to ${LT.this.dn42.IPv4}
            ip6 saddr != @DN42_IPV6 ip6 daddr @DN42_IPV6 ip6 daddr != @NEONETWORK_IPV6 ip6 daddr != @LOCAL_IPV6 oifname != @ZONE_WAN_INTERFACES snat to ${LT.this.dn42.IPv6}
          '';
        }
      ];
    })
  ];
}
