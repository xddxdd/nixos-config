{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  inherit (import ./common.nix args)
    DN42_AS DN42_TEST_AS DN42_REGION NEO_AS
    community latencyToDN42Community typeToDN42Community;

  peer = hostname: { ltnet, index, city, ... }:
    let
      latencyCommunity = builtins.toString (latencyToDN42Community {
        latencyMs = LT.geo.rttMs LT.this.city city;
        badRouting = false;
      });
    in
    lib.optionalString (!ltnet.alone) ''
      protocol bgp ltnet_${lib.toLower (LT.sanitizeName hostname)} from lantian_internal {
        local fc00::2547:${builtins.toString LT.this.index} as ${DN42_AS};
        neighbor fc00::2547:${builtins.toString index}%'zthnhe4bol' internal;
        ipv4 {
          import filter { dn42_update_flags(${latencyCommunity},24,34); ltnet_import_filter_v4(); };
          export filter { dn42_update_flags(${latencyCommunity},24,34); ltnet_export_filter_v4(); };
          cost ${builtins.toString (1 + LT.geo.rttMs LT.this.city city)};
        };
        ipv6 {
          import filter { dn42_update_flags(${latencyCommunity},24,34); ltnet_import_filter_v6(); };
          export filter { dn42_update_flags(${latencyCommunity},24,34); ltnet_export_filter_v6(); };
          cost ${builtins.toString (1 + LT.geo.rttMs LT.this.city city)};
        };
      };
    '';
in
{
  babel = ''
    function ltmesh_import_filter_v4() {
      if net ~ LTNET_IPv4 then accept;
      reject;
    }

    function ltmesh_export_filter_v4() {
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then reject;
      if net ~ LTNET_IPv4 then accept;
      reject;
    }

    function ltmesh_import_filter_v6() {
      if net ~ LTNET_IPv6 then accept;
      reject;
    }

    function ltmesh_export_filter_v6() {
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then reject;
      if net ~ LTNET_IPv6 then accept;
      reject;
    }

    protocol babel ltmesh {
      ipv4 {
        import filter { ltmesh_import_filter_v4(); };
        export filter { ltmesh_export_filter_v4(); };
      };
      ipv6 {
        import filter { ltmesh_import_filter_v6(); };
        export filter { ltmesh_export_filter_v6(); };
      };
      randomize router id yes;
      metric decay 30s;
      interface "zthnhe4bol" {
        type tunnel;
        rtt cost 1000;
        rtt min 0ms;
        rtt max 1000ms;
        rtt decay 42;
      };
    }
  '';

  common = ''
    function ltnet_import_filter_v4() {
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    function ltnet_export_filter_v4() {
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    function ltnet_import_filter_v6() {
      if net ~ RESERVED_IPv6 then accept;
      reject;
    }

    function ltnet_export_filter_v6() {
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
        add paths yes;
        import filter { ltnet_import_filter_v4(); };
        export filter { ltnet_export_filter_v4(); };
      };
      ipv6 {
        next hop self yes;
        import keep filtered;
        extended next hop yes;
        add paths yes;
        import filter { ltnet_import_filter_v6(); };
        export filter { ltnet_export_filter_v6(); };
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

  peers = builtins.concatStringsSep "\n" (lib.mapAttrsToList peer LT.otherHosts);
}
