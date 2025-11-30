{
  lib,
  LT,
  config,
  ...
}@args:
let
  inherit (import ./common.nix args)
    DN42_AS
    DN42_REGION
    NEO_AS
    community
    latencyToDN42Community
    typeToDN42Community
    ;

  peer =
    n: v:
    let
      interfaceName = "${v.peering.network}-${n}";
      latency = builtins.toString (latencyToDN42Community v);
      crypto = builtins.toString (typeToDN42Community v.tunnel.type);
      localASN = if v.peering.network == "dn42" then DN42_AS else NEO_AS;
    in
    if
      builtins.elem v.mode [
        "bad-routing"
        "flapping"
      ]
    then
      ""
    else
      lib.optionalString (v.addressing.peerIPv4 != null && !v.peering.mpbgp) ''
        protocol bgp ${lib.toLower (LT.sanitizeName interfaceName)}_v4 from dnpeers {
          neighbor ${v.addressing.peerIPv4} as ${builtins.toString v.remoteASN};
          local ${v.addressing.myIPv4} as ${localASN};
          multihop 1;
          ipv4 {
            import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(${localASN}); };
            export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(${localASN}); };
            gateway recursive;
          };
          ipv6 {
            import none;
            export none;
            gateway recursive;
          };
        };
      ''
      + lib.optionalString (v.addressing.peerIPv6 != null) ''
        protocol bgp ${lib.toLower (LT.sanitizeName interfaceName)}_v6 from dnpeers {
          neighbor ${v.addressing.peerIPv6} as ${builtins.toString v.remoteASN};
          local ${v.addressing.myIPv6} as ${localASN};
          multihop 1;
          ipv4 {
            import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(${localASN}); };
            export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(${localASN}); };
            gateway recursive;
          };
          ipv6 {
            import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv6(${localASN}); };
            export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv6(${localASN}); };
            gateway recursive;
          };
        };
      ''
      + lib.optionalString (v.addressing.peerIPv6LinkLocal != null) ''
        protocol bgp ${lib.toLower (LT.sanitizeName interfaceName)}_v6 from dnpeers {
          neighbor ${v.addressing.peerIPv6LinkLocal}%'${interfaceName}' as ${builtins.toString v.remoteASN};
          local ${v.addressing.myIPv6LinkLocal} as ${localASN};
          direct;
          ipv4 {
            import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv4(${localASN}); };
            export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv4(${localASN}); };
          };
          ipv6 {
            import filter { dn42_update_flags(${latency},24,${crypto}); dn42_import_filter_ipv6(${localASN}); };
            export filter { dn42_update_flags(${latency},24,${crypto}); dn42_export_filter_ipv6(${localASN}); };
          };
        };
      '';

  staticRoute4 =
    n: v:
    let
      interfaceName = "${v.peering.network}-${n}";
    in
    lib.optionalString (v.addressing.peerIPv4 != null) ''
      route ${v.addressing.peerIPv4}/32 via "${interfaceName}" {
        bgp_community.add(${community.NO_ADVERTISE});
      };
    '';

  staticRoute6 =
    n: v:
    let
      interfaceName = "${v.peering.network}-${n}";
    in
    lib.optionalString (v.addressing.peerIPv6 != null) ''
      route ${v.addressing.peerIPv6}/128 via "${interfaceName}" {
        bgp_community.add(${community.NO_ADVERTISE});
      };
    '';

  cfg = config.services.dn42 or { };
in
{
  common = ''
    function dn42_import_filter_ipv4(int local_asn) {
      if (roa_check(roa_v4, net, bgp_path.last) = ROA_INVALID) then {
        bgp_large_community.add(${community.LT_ROA_FAIL});
        bgp_large_community.add(${community.LT_POLICY_NO_KERNEL});
        bgp_community.add(${community.NO_EXPORT});
        bgp_local_pref = 0;
      } else if (roa_check(roa_v4, net, bgp_path.last) = ROA_UNKNOWN) then {
        bgp_large_community.add(${community.LT_ROA_UNKNOWN});
        # bgp_large_community.add(${community.LT_POLICY_NO_KERNEL});
        # bgp_community.add(${community.NO_EXPORT});
        # bgp_local_pref = 0;
      }
      if net ~ RESERVED_IPv4 then accept;
      reject;
    }

    function dn42_export_filter_ipv4(int local_asn) {
      bgp_path.delete(${DN42_AS});
      bgp_path.delete([4225470000..4225479999]);
      if net !~ RESERVED_IPv4 then reject;

      # Reduce flapping across DN42 network
      if net ~ FLAPPING_IPv4 then reject;

      if ${community.NO_EXPORT} ~ bgp_community then reject;
      if ${community.NO_ADVERTISE} ~ bgp_community then reject;

      if net ~ [ 172.22.76.184/29+ ] then bgp_path.prepend(${DN42_AS});
      if net ~ [ 172.22.76.96/27+ ] then bgp_path.prepend(${DN42_AS});
      if net ~ [ 10.127.10.0/24+ ] then bgp_path.prepend(${NEO_AS});

      accept;
    }

    function dn42_import_filter_ipv6(int local_asn) {
      if (roa_check(roa_v6, net, bgp_path.last) = ROA_INVALID) then {
        bgp_large_community.add(${community.LT_ROA_FAIL});
        bgp_large_community.add(${community.LT_POLICY_NO_KERNEL});
        bgp_community.add(${community.NO_EXPORT});
        bgp_local_pref = 0;
      } else if (roa_check(roa_v6, net, bgp_path.last) = ROA_UNKNOWN) then {
        bgp_large_community.add(${community.LT_ROA_UNKNOWN});
        # bgp_large_community.add(${community.LT_POLICY_NO_KERNEL});
        # bgp_community.add(${community.NO_EXPORT});
        # bgp_local_pref = 0;
      }
      if net ~ RESERVED_IPv6 then accept;
      reject;
    };

    function dn42_export_filter_ipv6(int local_asn) {
      bgp_path.delete(${DN42_AS});
      bgp_path.delete([4225470000..4225479999]);
      if net !~ RESERVED_IPv6 then reject;

      # Reduce flapping across DN42 network
      if net ~ FLAPPING_IPv6 then reject;

      if ${community.NO_EXPORT} ~ bgp_community then reject;
      if ${community.NO_ADVERTISE} ~ bgp_community then reject;

      if net ~ [ fdbc:f9dc:67ad::/48+ ] then bgp_path.prepend(${DN42_AS});
      if net ~ [ fd10:127:10::/48+ ] then bgp_path.prepend(${NEO_AS});

      accept;
    };

    template bgp dnpeers {
      local as ${DN42_AS};
      path metric yes;
      enable extended messages on;
      enforce first as on;

      graceful restart yes;
      # DO NOT USE: causes delayed updates when network is unstable
      # long lived graceful restart yes;

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

  staticRoutes = ''
    protocol static static_v4_dn42 {
      ${lib.concatMapAttrsStringSep "\n" staticRoute4 cfg}
      ipv4 {
        preference 9999;
        import all;
        export none;
      };
    }

    protocol static static_v6_dn42 {
      ${lib.concatMapAttrsStringSep "\n" staticRoute6 cfg}
      ipv6 {
        preference 9999;
        import all;
        export none;
      };
    }
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

      # # Disabled since I removed latency records for peerings

      # if dn42_get_region() = ${DN42_REGION} && dn42_latency <= 5 then {
      #   bgp_local_pref = bgp_local_pref + 100;
      # }

      # bgp_local_pref = bgp_local_pref - dn42_latency;
      # bgp_local_pref = bgp_local_pref - 10 * bgp_path.len;

      return true;
    }
  '';

  grc = ''
    # GRC config must be below dn42 & neonetwork since it uses filters from them
    template bgp dnpeers_grc {
      multihop;

      graceful restart yes;
      # DO NOT USE: causes delayed updates when network is unstable
      # long lived graceful restart yes;

      ipv4 {
        add paths tx;
        import none;
        export filter { dn42_export_filter_ipv4(${DN42_AS}); };
      };

      ipv6 {
        add paths tx;
        import none;
        export filter { dn42_export_filter_ipv6(${DN42_AS}); };
      };
    }
    protocol bgp dn42_grc_v4 from dnpeers_grc {
      local ${LT.this.dn42.IPv4} as ${DN42_AS};
      neighbor 172.20.0.179 as 4242422602;
    }
    protocol bgp dn42_grc_v6 from dnpeers_grc{
      local ${LT.this.dn42.IPv6} as ${DN42_AS};
      neighbor fd42:d42:d42:179::1 as 4242422602;
    }
  '';

  hasPeers = cfg != { };

  peers = lib.concatMapAttrsStringSep "\n" peer cfg;
}
