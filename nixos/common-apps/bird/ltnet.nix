{ config, pkgs, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };
  inherit (import ./common.nix { inherit config pkgs; })
    DN42_AS DN42_REGION NEO_AS
    community sanitizeHostname;

  peer = hostname: { ltnet, index, ... }:
    pkgs.lib.optionalString (!(ltnet.alone or false)) ''
      protocol bgp ltnet_${sanitizeHostname hostname} from lantian_internal {
        neighbor fe80::${builtins.toString index}%'ltmesh' internal;
      };
    '';
in
{
  common = ''
    filter ltnet_import_filter_v4 {
      if bgp_local_pref > 5 then {
        bgp_local_pref = bgp_local_pref - 5;
      } else {
        bgp_local_pref = 0;
      }
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    filter ltnet_export_filter_v4 {
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    filter ltnet_import_filter_v6 {
      if bgp_local_pref > 5 then {
        bgp_local_pref = bgp_local_pref - 5;
      } else {
        bgp_local_pref = 0;
      }
      if net ~ RESERVED_IPv6 then accept;
      reject;
    }

    filter ltnet_export_filter_v6 {
      if net ~ RESERVED_IPv6 then accept;
      reject;
    }

    template bgp lantian_internal {
      local fe80::${builtins.toString LT.this.index} as ${DN42_AS};
      direct;
      enable extended messages on;
      hold time 30;
      keepalive time 3;
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

  peers = builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList peer LT.otherHosts);
}
