{ config, pkgs, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };
  inherit (import ./common.nix { inherit config pkgs; })
    DN42_AS DN42_REGION NEO_AS
    community sanitizeHostname;

  filterNetwork = net: pkgs.lib.filterAttrs (n: v: v.peering.network == net);

  latencyToDN42Community = { latencyMs, badRouting, ... }:
    if badRouting then 9 else
    if latencyMs <= 3 then 1 else
    if latencyMs <= 7 then 2 else
    if latencyMs <= 20 then 3 else
    if latencyMs <= 55 then 4 else
    if latencyMs <= 148 then 5 else
    if latencyMs <= 403 then 6 else
    if latencyMs <= 1097 then 7 else
    if latencyMs <= 2981 then 8 else
    9;

  typeToDN42Community = type:
    if type == "openvpn" then 33 else
    if type == "wireguard" then 34 else
    if type == "gre" then 31 else
    31;

  peer = n: v:
    let
      interfaceName = "${v.peering.network}-${n}";
      latency = builtins.toString (latencyToDN42Community v);
      crypto = builtins.toString (typeToDN42Community v.tunnel.type);
      localASN = if v.peering.network == "dn42" then DN42_AS else NEO_AS;
    in
    pkgs.lib.optionalString (v.addressing.peerIPv4 != null && !v.peering.mpbgp) ''
      protocol bgp ${sanitizeHostname interfaceName}_v4 from dnpeers {
        neighbor ${v.addressing.peerIPv4} as ${builtins.toString v.remoteASN};
        local ${v.addressing.myIPv4} as ${localASN};
        ipv4 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(); };
        };
        ipv6 {
          import none;
          export none;
        };
      };
    ''
    + pkgs.lib.optionalString (v.addressing.peerIPv6 != null) ''
      protocol bgp ${sanitizeHostname interfaceName}_v6 from dnpeers {
        neighbor ${v.addressing.peerIPv6} as ${builtins.toString v.remoteASN};
        local ${v.addressing.myIPv6} as ${localASN};
        ipv4 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(); };
        };
        ipv6 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv6(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv6(); };
        };
      };
    ''
    + pkgs.lib.optionalString (v.addressing.peerIPv6Subnet != null) ''
      protocol bgp ${sanitizeHostname interfaceName}_v6 from dnpeers {
        neighbor ${v.addressing.peerIPv6Subnet} as ${builtins.toString v.remoteASN};
        local ${v.addressing.myIPv6Subnet} as ${localASN};
        ipv4 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(); };
        };
        ipv6 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv6(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv6(); };
        };
      };
    ''
    + pkgs.lib.optionalString (v.addressing.peerIPv6LinkLocal != null) ''
      protocol bgp ${sanitizeHostname interfaceName}_v6 from dnpeers {
        neighbor ${v.addressing.peerIPv6LinkLocal}%'${interfaceName}' as ${builtins.toString v.remoteASN};
        local ${v.addressing.myIPv6LinkLocal} as ${localASN};
        ipv4 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(); };
        };
        ipv6 {
          import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv6(); };
          export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv6(); };
        };
      };
    ''
  ;
in
{
  common = ''
    function dn42_import_filter_ipv4() {
      if (roa_check(roa_v4, net, bgp_path.last) = ROA_INVALID) then {
        bgp_large_community.add(${community.LT_ROA_FAIL});
        bgp_large_community.add(${community.LT_POLICY_NOEXPORT});
        bgp_local_pref = 0;
      } else if (roa_check(roa_v4, net, bgp_path.last) = ROA_UNKNOWN) then {
        bgp_large_community.add(${community.LT_ROA_UNKNOWN});
        # bgp_large_community.add(${community.LT_POLICY_NOEXPORT});
        # bgp_local_pref = 0;
      }
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    function dn42_export_filter_ipv4() {
      bgp_path.delete(${DN42_AS});
      bgp_path.delete([4225470000..4225479999]);
      if net !~ RESERVED_IPv4 then reject;
      if ${community.LT_POLICY_NOEXPORT} ~ bgp_large_community then reject;

      if net ~ [ 172.22.76.184/29+ ] then bgp_path.prepend(${DN42_AS});
      if net ~ [ 172.22.76.96/27+ ] then bgp_path.prepend(${DN42_AS});
      if net ~ [ 10.127.10.0/24+ ] then bgp_path.prepend(${NEO_AS});

      if (
        (bgp_path.last != 0 && roa_check(roa_v4, net, bgp_path.last) != ROA_VALID)
        || (bgp_path.last = 0 && roa_check(roa_v4, net, ${DN42_AS}) != ROA_VALID)
      ) then {
        #print "[dn42 export] roa fail for ", net, " as ", bgp_path.last, " neighbor ", bgp_path.first;
        reject;
      }
      accept;
    }

    function dn42_import_filter_ipv6() {
      if (roa_check(roa_v6, net, bgp_path.last) = ROA_INVALID) then {
        bgp_large_community.add(${community.LT_ROA_FAIL});
        bgp_large_community.add(${community.LT_POLICY_NOEXPORT});
        bgp_local_pref = 0;
      } else if (roa_check(roa_v6, net, bgp_path.last) = ROA_UNKNOWN) then {
        bgp_large_community.add(${community.LT_ROA_UNKNOWN});
        # bgp_large_community.add(${community.LT_POLICY_NOEXPORT});
        # bgp_local_pref = 0;
      }
      if net ~ RESERVED_IPv6 then accept;
      reject;
    };

    function dn42_export_filter_ipv6() {
      bgp_path.delete(${DN42_AS});
      bgp_path.delete([4225470000..4225479999]);
      if net !~ RESERVED_IPv6 then reject;
      if ${community.LT_POLICY_NOEXPORT} ~ bgp_large_community then reject;

      if net ~ [ fdbc:f9dc:67ad::/48+ ] then bgp_path.prepend(${DN42_AS});
      if net ~ [ fd10:127:10::/48+ ] then bgp_path.prepend(${NEO_AS});

      if (
        (bgp_path.last != 0 && roa_check(roa_v6, net, bgp_path.last) != ROA_VALID)
        || (bgp_path.last = 0 && roa_check(roa_v6, net, ${DN42_AS}) != ROA_VALID)
      ) then {
        #print "[dn42 export] roa fail for ", net, " as ", bgp_path.last, " neighbor ", bgp_path.first;
        reject;
      }
      accept;
    };

    template bgp dnpeers {
      local as ${DN42_AS};
      path metric 1;
      direct;
      enable extended messages on;
      enforce first as on;
      ipv4 {
        next hop self yes;
        import keep filtered;
        extended next hop yes;
      };
      ipv6 {
        next hop self yes;
        import keep filtered;
        extended next hop yes;
      };
    };
  '';

  communityFilters = ''
    function dn42_update_latency(int link_latency) {
      bgp_community.add((64511, link_latency));
          if (64511, 9) ~ bgp_community then { bgp_community.delete([(64511, 1..8)]); return 9; }
      else if (64511, 8) ~ bgp_community then { bgp_community.delete([(64511, 1..7)]); return 8; }
      else if (64511, 7) ~ bgp_community then { bgp_community.delete([(64511, 1..6)]); return 7; }
      else if (64511, 6) ~ bgp_community then { bgp_community.delete([(64511, 1..5)]); return 6; }
      else if (64511, 5) ~ bgp_community then { bgp_community.delete([(64511, 1..4)]); return 5; }
      else if (64511, 4) ~ bgp_community then { bgp_community.delete([(64511, 1..3)]); return 4; }
      else if (64511, 3) ~ bgp_community then { bgp_community.delete([(64511, 1..2)]); return 3; }
      else if (64511, 2) ~ bgp_community then { bgp_community.delete([(64511, 1..1)]); return 2; }
      else return 1;
    }

    function dn42_update_bandwidth(int link_bandwidth) {
      bgp_community.add((64511, link_bandwidth));
          if (64511, 21) ~ bgp_community then { bgp_community.delete([(64511, 22..29)]); return 21; }
      else if (64511, 22) ~ bgp_community then { bgp_community.delete([(64511, 23..29)]); return 22; }
      else if (64511, 23) ~ bgp_community then { bgp_community.delete([(64511, 24..29)]); return 23; }
      else if (64511, 24) ~ bgp_community then { bgp_community.delete([(64511, 25..29)]); return 24; }
      else if (64511, 25) ~ bgp_community then { bgp_community.delete([(64511, 26..29)]); return 25; }
      else if (64511, 26) ~ bgp_community then { bgp_community.delete([(64511, 27..29)]); return 26; }
      else if (64511, 27) ~ bgp_community then { bgp_community.delete([(64511, 28..29)]); return 27; }
      else if (64511, 28) ~ bgp_community then { bgp_community.delete([(64511, 29..29)]); return 28; }
      else return 29;
    }

    function dn42_update_crypto(int link_crypto) {
      bgp_community.add((64511, link_crypto));
          if (64511, 31) ~ bgp_community then { bgp_community.delete([(64511, 32..34)]); return 31; }
      else if (64511, 32) ~ bgp_community then { bgp_community.delete([(64511, 33..34)]); return 32; }
      else if (64511, 33) ~ bgp_community then { bgp_community.delete([(64511, 34..34)]); return 33; }
      else return 34;
    }

    function dn42_get_region() {
          if (64511, 41) ~ bgp_community then { return 41; }
      else if (64511, 42) ~ bgp_community then { return 42; }
      else if (64511, 43) ~ bgp_community then { return 43; }
      else if (64511, 44) ~ bgp_community then { return 44; }
      else if (64511, 45) ~ bgp_community then { return 45; }
      else if (64511, 46) ~ bgp_community then { return 46; }
      else if (64511, 47) ~ bgp_community then { return 47; }
      else if (64511, 48) ~ bgp_community then { return 48; }
      else if (64511, 49) ~ bgp_community then { return 49; }
      else if (64511, 50) ~ bgp_community then { return 50; }
      else if (64511, 51) ~ bgp_community then { return 51; }
      else if (64511, 52) ~ bgp_community then { return 52; }
      else if (64511, 53) ~ bgp_community then { return 53; }
      else return 0;
    }

    function dn42_update_flags(int link_latency; int link_bandwidth; int link_crypto)
    int dn42_latency;
    int dn42_bandwidth;
    int dn42_crypto;
    {
      dn42_latency = dn42_update_latency(link_latency);
      dn42_bandwidth = dn42_update_bandwidth(link_bandwidth) - 20;
      dn42_crypto = dn42_update_crypto(link_crypto) - 30;
      if source != RTS_BGP then { bgp_community.add((64511, ${DN42_REGION})); }

      bgp_local_pref = 200;

      if dn42_get_region() = ${DN42_REGION} && dn42_latency <= 5 then {
        bgp_local_pref = bgp_local_pref + 100;
      }

      bgp_local_pref = bgp_local_pref - dn42_latency;
      bgp_local_pref = bgp_local_pref - 10 * bgp_path.len;

      return true;
    }
  '';

  grc = ''
    # GRC config must be below dn42 & neonetwork since it uses filters from them
    protocol bgp dn42_burble_grc {
      local ${LT.this.dn42.IPv6} as ${DN42_AS};
      neighbor fd42:4242:2601:ac12::1 as 4242422602;
      multihop;

      ipv4 {
        add paths tx;
        import none;
        export filter { dn42_export_filter_ipv4(); };
      };

      ipv6 {
        add paths tx;
        import none;
        export filter { dn42_export_filter_ipv4(); };
      };
    }
  '';

  peers = builtins.concatStringsSep "\n"
    (pkgs.lib.mapAttrsToList peer (filterNetwork "dn42" (config.services.dn42 or { })));
}
