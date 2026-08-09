{
  lib,
  LT,
  config,
  ...
}:
let
  inherit (import ./common.nix { inherit lib LT; }) ipv4Set ipv6Set interfaceSet;

  wanARPSubnets = config.lantian.firewall.wanARPSubnets;
  wanICMPv6Subnets = config.lantian.firewall.wanICMPv6Subnets;
  wanInterfaceSet = interfaceSet "WAN" LT.constants.interfacePrefixes.WAN;

  # An empty wanARPSubnets would make an empty set (invalid nft syntax), so a
  # dummy 0.0.0.0/32 matching no real traffic is used in block-all mode.
  arpRules = lib.optionalString (wanARPSubnets != null) ''
    ${wanInterfaceSet}
    ${ipv4Set "WAN_ARP_SUBNETS" (if wanARPSubnets == [ ] then [ "0.0.0.0/32" ] else wanARPSubnets)}

    chain INPUT {
      type filter hook input priority 0; policy accept;
      iifname @INTERFACE_WAN arp saddr ip != @WAN_ARP_SUBNETS drop
    }

    chain OUTPUT {
      type filter hook output priority 0; policy accept;
      oifname @INTERFACE_WAN arp daddr ip != @WAN_ARP_SUBNETS drop
    }
  '';

  # fe80::/10 is always allowed so link-local NDP keeps working; in block-all
  # mode ([ ]) only global NS/NA are dropped.
  icmpv6Rules = lib.optionalString (wanICMPv6Subnets != null) ''
    ${wanInterfaceSet}
    ${ipv6Set "WAN_ICMPV6_SUBNETS" (wanICMPv6Subnets ++ [ "fe80::/10" ])}

    chain INPUT {
      type filter hook input priority 10; policy accept;
      iifname @INTERFACE_WAN ip6 nexthdr icmpv6 icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } ip6 saddr != @WAN_ICMPV6_SUBNETS drop
    }

    chain OUTPUT {
      type filter hook input priority 10; policy accept;
      iifname @INTERFACE_WAN ip6 nexthdr icmpv6 icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } ip6 daddr != @WAN_ICMPV6_SUBNETS drop
    }
  '';
in
{
  options.lantian.firewall = {
    wanARPSubnets = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = ''
        IPv4 subnet CIDRs whose ARP traffic is allowed on WAN interfaces.
        - null (default): ARP filter disabled, no table is created.
        - empty list [ ]: block all ARP request/reply on WAN interfaces.
        - non-empty list: only allow ARP whose source or destination
          protocol address is within one of the listed subnets.
      '';
    };

    wanICMPv6Subnets = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = ''
        IPv6 subnet CIDRs whose ICMPv6 neighbor solicitation / advertisement
        traffic is allowed on WAN interfaces.
        - null (default): filter disabled, no table is created.
        - empty list [ ]: allow link-local (fe80::/10) NS/NA only, drop all
          global NS/NA on WAN interfaces.
        - non-empty list: allow NS/NA for the listed subnets plus fe80::/10,
          drop everything else.
      '';
    };
  };

  config = {
    networking.nftables.tables =
      (lib.optionalAttrs (wanARPSubnets != null) {
        lantian_arp = {
          family = "arp";
          content = arpRules;
        };
      })
      // (lib.optionalAttrs (wanICMPv6Subnets != null) {
        lantian_icmpv6 = {
          family = "inet";
          content = icmpv6Rules;
        };
      });
  };
}
