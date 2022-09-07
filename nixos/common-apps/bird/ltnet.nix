{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };
  inherit (import ./common.nix { inherit config pkgs lib; })
    DN42_AS DN42_TEST_AS DN42_REGION NEO_AS
    community sanitizeHostname;

  peer = hostname: { ltnet, index, ... }:
    lib.optionalString (!ltnet.alone) ''
      protocol bgp ltnet_${sanitizeHostname hostname} from lantian_internal {
        local fdbc:f9dc:67ad:${builtins.toString LT.this.index}::1 as ${DN42_AS};
        neighbor fdbc:f9dc:67ad:${builtins.toString index}::1 internal;
      };
    '';
in
{
  babel = ''
    filter ltmesh_import_filter_v4 {
      if net ~ LTNET_IPv4 then accept;
      reject;
    }

    filter ltmesh_export_filter_v4 {
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then reject;
      if net ~ LTNET_IPv4 then accept;
      reject;
    }

    filter ltmesh_import_filter_v6 {
      if net ~ LTNET_IPv6 then accept;
      reject;
    }

    filter ltmesh_export_filter_v6 {
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then reject;
      if net ~ LTNET_IPv6 then accept;
      reject;
    }

    protocol babel ltmesh {
      ipv4 {
        import filter ltmesh_import_filter_v4;
        export filter ltmesh_export_filter_v4;
      };
      ipv6 {
        import filter ltmesh_import_filter_v6;
        export filter ltmesh_export_filter_v6;
      };
      randomize router id yes;
      metric decay 30s;
      interface "ltmesh*" {
        type tunnel;
        rtt cost 1000;
        rtt min 0ms;
        rtt max 1000ms;
        rtt decay 42;
      };
    }
  '';

  common = ''
    filter ltnet_import_filter_v4 {
      if bgp_local_pref > 5 then {
        bgp_local_pref = bgp_local_pref - 5;
      } else {
        bgp_local_pref = 0;
      }
      if net ~ LTNET_IPv4 then reject;
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    filter ltnet_export_filter_v4 {
      if net ~ LTNET_IPv4 then reject;
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    filter ltnet_import_filter_v6 {
      if bgp_local_pref > 5 then {
        bgp_local_pref = bgp_local_pref - 5;
      } else {
        bgp_local_pref = 0;
      }
      if net ~ LTNET_IPv6 then reject;
      if net ~ RESERVED_IPv6 then accept;
      reject;
    }

    filter ltnet_export_filter_v6 {
      if net ~ LTNET_IPv6 then reject;
      if net ~ RESERVED_IPv6 then accept;
      reject;
    }

    template bgp lantian_internal {
      enable extended messages on;
      hold time 30;
      keepalive time 3;
      graceful restart yes;
      long lived graceful restart yes;

      ipv4 {
        next hop self yes;
        import keep filtered;
        ${lib.optionalString (!LT.this.openvz) "extended next hop yes;"}
        add paths yes;
        import filter ltnet_import_filter_v4;
        export filter ltnet_export_filter_v4;
      };
      ipv6 {
        next hop self yes;
        import keep filtered;
        ${lib.optionalString (!LT.this.openvz) "extended next hop yes;"}
        add paths yes;
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
      long lived graceful restart yes;
      dynamic name "ltdyn_v4_";
    };
    protocol bgp ltdyn_v6 from lantian_internal {
      local as ${DN42_AS};
      neighbor range ${LT.this.ltnet.IPv6Prefix}::0/64 as ${DN42_TEST_AS};
      graceful restart yes;
      long lived graceful restart yes;
      dynamic name "ltdyn_v6_";
    };
  '';

  peers = builtins.concatStringsSep "\n" (lib.mapAttrsToList peer LT.otherHosts);
}
