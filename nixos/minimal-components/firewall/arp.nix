{
  lib,
  LT,
  config,
  ...
}:
let
  inherit (import ./common.nix { inherit lib LT; }) ipv4Set interfaceSet;

  wanARPSubnets = config.lantian.firewall.wanARPSubnets;
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
  };

  config = {
    networking.nftables.tables = lib.optionalAttrs (wanARPSubnets != null) {
      lantian_arp = {
        family = "arp";
        content = arpRules;
      };
    };
  };
}
