{ lib, LT, ... }@args:
let
  inherit (import ./common.nix args) DN42_AS DN42_TEST_AS;

  peer =
    hostname:
    {
      index,
      city,
      ...
    }:
    ''
      protocol bgp ltnet_${lib.toLower (LT.sanitizeName hostname)} from lantian_internal {
        local fdbc:f9dc:67ad::${builtins.toString LT.this.index} as ${DN42_AS};
        neighbor fdbc:f9dc:67ad::${builtins.toString index} internal;
        multihop;
        # NEVER cause local_pref inversion on iBGP routes!
        ipv4 {
          import filter ltnet_import_filter_v4;
          export filter ltnet_export_filter_v4;
          cost ${builtins.toString (1 + LT.geo.rttMs LT.this.city city)};
        };
        ipv6 {
          import filter ltnet_import_filter_v6;
          export filter ltnet_export_filter_v6;
          cost ${builtins.toString (1 + LT.geo.rttMs LT.this.city city)};
        };
      };
    '';
in
{
  babel = ''
    filter ltbabel_filter_v4 {
      if net ~ COMMON_STATIC_IPv4 then reject;
      if net ~ LTNET_UNMANAGED_IPv4 then reject;
      if net ~ LTNET_IPv4 then accept;
      reject;
    }

    filter ltbabel_filter_v6 {
      if net ~ COMMON_STATIC_IPv6 then reject;
      if net ~ LTNET_UNMANAGED_IPv6 then reject;
      if net ~ LTNET_IPv6 then accept;
      reject;
    }

    protocol babel ltbabel {
      ipv4 {
        import filter ltbabel_filter_v4;
        export filter ltbabel_filter_v4;
      };
      ipv6 {
        import filter ltbabel_filter_v6;
        export filter ltbabel_filter_v6;
      };
      randomize router id yes;
      interface "wgmesh*" {
        type tunnel;
        rtt cost 1000;
        rtt min 0ms;
        rtt max 1000ms;
        rtt decay 10;
      };
    }
  '';

  common = ''
    filter ltnet_import_filter_v4 {
      if net ~ LTNET_UNMANAGED_IPv4 then reject;
      if net ~ LTNET_IPv4 then reject;
      if net ~ RESERVED_IPv4 then accept;
      if net ~ REROUTED_WAN_IPv4 then accept;
      reject;
    }

    filter ltnet_export_filter_v4 {
      if net ~ REROUTED_WAN_IPv4 then accept;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then reject;
      if ifindex = 0 then reject;
      if net ~ LTNET_UNMANAGED_IPv4 then reject;
      if net ~ LTNET_IPv4 then reject;
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    filter ltnet_import_filter_v6 {
      if net ~ LTNET_UNMANAGED_IPv6 then reject;
      if net ~ LTNET_IPv6 then reject;
      if net ~ RESERVED_IPv6 then accept;
      if net ~ REROUTED_WAN_IPv6 then accept;
      reject;
    }

    filter ltnet_export_filter_v6 {
      if net ~ REROUTED_WAN_IPv6 then accept;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then reject;
      if ifindex = 0 then reject;
      if net ~ LTNET_UNMANAGED_IPv6 then reject;
      if net ~ LTNET_IPv6 then reject;
      if net ~ RESERVED_IPv6 then accept;
      reject;
    }

    template bgp lantian_internal {
      direct;
      enable extended messages on;
      hold time 30;
      keepalive time 3;

      graceful restart yes;
      # DO NOT USE: causes delayed updates when network is unstable
      # long lived graceful restart yes;

      ipv4 {
        next hop self yes;
        import keep filtered;
        extended next hop yes;
        import filter ltnet_import_filter_v4;
        export filter ltnet_export_filter_v4;
      };
      ipv6 {
        next hop self yes;
        import keep filtered;
        extended next hop yes;
        import filter ltnet_import_filter_v6;
        export filter ltnet_export_filter_v6;
      };
    };
  '';

  dynamic = ''
    protocol bgp ltdyn_v4 from lantian_internal {
      local as ${DN42_AS};
      neighbor range ${LT.this.ltnet.IPv4Prefix}.0/24 as ${DN42_TEST_AS};

      graceful restart yes;
      # DO NOT USE: causes delayed updates when network is unstable
      # long lived graceful restart yes;

      dynamic name "ltdyn_v4_";
    };
    protocol bgp ltdyn_v6 from lantian_internal {
      local as ${DN42_AS};
      neighbor range ${LT.this.ltnet.IPv6Prefix}::0/64 as ${DN42_TEST_AS};

      graceful restart yes;
      # DO NOT USE: causes delayed updates when network is unstable
      # long lived graceful restart yes;

      dynamic name "ltdyn_v6_";
    };
  '';

  peers = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList peer (
      lib.filterAttrs (n: v: LT.this.hasTag LT.tags.server && v.hasTag LT.tags.server) LT.otherHosts
    )
  );
}
