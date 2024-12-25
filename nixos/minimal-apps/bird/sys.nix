{
  config,
  lib,
  LT,
  ...
}@args:
let
  inherit (import ./common.nix args) community;

  excludedInterfacesFromDirect = [
    "dn42-*"
    "neo-*"
    "zt*"
  ];
in
{
  common = ''
    log stderr { warning, error, fatal };
    router id ${if LT.this.dn42.IPv4 != "" then LT.this.dn42.IPv4 else LT.this.ltnet.IPv4};
    timeformat protocol iso long;
    #debug protocols all;
  '';

  kernel = ''
    filter sys_import_v4 {
      if net !~ RESERVED_IPv4 then reject;
      if net !~ LTNET_IPv4 && net.len = 32 then reject;
      bgp_large_community.add(${community.LT_POLICY_NO_EXPORT});
      accept;
    }

    filter sys_import_v6 {
      if net !~ RESERVED_IPv6 then reject;
      if net !~ LTNET_IPv6 && net.len = 128 then reject;
      bgp_large_community.add(${community.LT_POLICY_NO_EXPORT});
      accept;
    }

    filter sys_export_v4 {
      if net ~ LTNET_UNMANAGED_IPv4 then reject;
      if ${community.LT_POLICY_NO_KERNEL} ~ bgp_large_community then reject;
      ${lib.optionalString (LT.this.hasTag LT.tags.dn42) "if ${community.LT_POLICY_INTERNAL_AGGREGATED} ~ bgp_large_community then reject;"}
      if ${community.LT_POLICY_DROP} ~ bgp_large_community then dest = RTD_UNREACHABLE;

      krt_metric = 4242;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then {
        krt_metric = 65535;
        if net ~ REROUTED_WAN_IPv4 then reject;
      }

      krt_prefsrc = ${LT.this.ltnet.IPv4};
      ${
        lib.optionalString (
          LT.this.dn42.IPv4 != ""
        ) "if net ~ DN42_NET_IPv4 then krt_prefsrc = ${LT.this.dn42.IPv4};"
      }
      ${
        lib.optionalString (
          LT.this.neonetwork.IPv4 != ""
        ) "if net ~ NEONETWORK_NET_IPv4 then krt_prefsrc = ${LT.this.neonetwork.IPv4};"
      }

      accept;
    }

    filter sys_export_v6 {
      if net ~ LTNET_UNMANAGED_IPv6 then reject;
      if ${community.LT_POLICY_NO_KERNEL} ~ bgp_large_community then reject;
      ${lib.optionalString (LT.this.hasTag LT.tags.dn42) "if ${community.LT_POLICY_INTERNAL_AGGREGATED} ~ bgp_large_community then reject;"}
      if ${community.LT_POLICY_DROP} ~ bgp_large_community then dest = RTD_UNREACHABLE;

      krt_metric = 4242;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then {
        krt_metric = 65535;
        if net ~ REROUTED_WAN_IPv6 then reject;
      }

      krt_prefsrc = ${LT.this.ltnet.IPv6};
      ${
        lib.optionalString (
          LT.this.dn42.IPv4 != ""
        ) "if net ~ DN42_NET_IPv6 then krt_prefsrc = ${LT.this.dn42.IPv6};"
      }
      ${
        lib.optionalString (
          LT.this.neonetwork.IPv4 != ""
        ) "if net ~ NEONETWORK_NET_IPv6 then krt_prefsrc = ${LT.this.neonetwork.IPv6};"
      }

      accept;
    }

    # # Disabled since internal routes are now managed with ZeroTier
    # protocol direct sys_direct {
    #   interface ${lib.concatMapStringsSep ", " (v: ''"-${v}"'') excludedInterfacesFromDirect}, "*";
    #   ipv4 {
    #     preference 10000;
    #     import filter sys_import_v4;
    #     export none;
    #   };
    #   ipv6 {
    #     preference 10000;
    #     import filter sys_import_v6;
    #     export none;
    #   };
    # };

    protocol kernel sys_kernel_v4 {
      scan time 20;
      learn;
      metric 0;
      ipv4 {
        preference 100;
        import filter sys_import_v4;
        export filter sys_export_v4;
      };
    };

    protocol kernel sys_kernel_v6 {
      scan time 20;
      learn;
      metric 0;
      ipv6 {
        preference 100;
        import filter sys_import_v6;
        export filter sys_export_v6;
      };
    };
  '';

  network = ''
    # DN42 & NetNetwork ranges for setting source addresses
    define DN42_NET_IPv4 = [
      172.20.0.0/14+,       # dn42

      172.31.0.0/16+,       # ChaosVPN
      10.100.0.0/14+,       # ChaosVPN

      # NeoNetwork is in another independent entry
      #10.127.0.0/16+,       # NeoNetwork

      10.0.0.0/8+     # Freifunk.net
    ];

    define DN42_NET_IPv6 = [
      fd00::/8+
    ];

    define DN42_HIGH_BW_IPv4 = [
      # nothing
    ];

    define DN42_HIGH_BW_IPv6 = [
      fdcf:8538:9ad5::/48+    # Kioubit's IPv6 canvas
    ];

    define LTNET_IPv4 = [
      10.127.10.0/24+,
      198.18.0.0/15+,
      172.22.76.184/29+,
      172.22.76.96/27+
    ];

    define LTNET_IPv6 = [
      fdbc:f9dc:67ad::/48+,
      fd10:127:10::/48+
    ];

    # IP ranges managed by other networking tools
    define LTNET_UNMANAGED_IPv4 = [
      192.168.0.0/16+,
      198.18.0.0/24+
    ];

    # IP ranges managed by other networking tools
    define LTNET_UNMANAGED_IPv6 = [
      fc00:192:168::/48+,
      fdbc:f9dc:67ad::/64+
    ];

    define NEONETWORK_NET_IPv4 = [
      10.127.0.0/16+
    ];

    define NEONETWORK_NET_IPv6 = [
      fd10:127::/32+
    ];

    define REROUTED_WAN_IPv4 = [
      168.63.129.16/32  # Azure private DNS server
    ];

    define REROUTED_WAN_IPv6 = [
      # nothing
    ];

    # Reserved range, where system is allowed to operate
    define RESERVED_IPv4 = [
    ${lib.concatMapStringsSep ",\n" (t: t + "+") LT.constants.reserved.IPv4}
    ];

    define RESERVED_IPv6 = [
    ${lib.concatMapStringsSep ",\n" (t: t + "+") LT.constants.reserved.IPv6}
    ];
  '';

  roa = ''
    roa4 table roa_v4;
    roa6 table roa_v6;

    protocol static static_roa4 {
      roa4 {
        table roa_v4;
      };
      include "/nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa4.conf";
      include "/nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa4.conf";
    };

    protocol static static_roa6 {
      roa6 {
        table roa_v6;
      };
      include "/nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_bird2_roa6.conf";
      include "/nix/persistent/sync-servers/ltnet-scripts/bird/neonetwork/neonetwork_bird2_roa6.conf";
    };
  '';

  roaMonitor = ''
    ipv4 table roa_fail_v4;
    ipv4 table roa_unknown_v4;
    ipv6 table roa_fail_v6;
    ipv6 table roa_unknown_v6;

    protocol pipe sys_roa_fail_v4 {
      table master4;
      peer table roa_fail_v4;
      export filter {
        if ${community.LT_ROA_FAIL} ~ bgp_large_community then accept;
        reject;
      };
    };

    protocol pipe sys_roa_unknown_v4 {
      table master4;
      peer table roa_unknown_v4;
      export filter {
        if ${community.LT_ROA_UNKNOWN} ~ bgp_large_community then accept;
        reject;
      };
    };

    protocol pipe sys_roa_fail_v6 {
      table master6;
      peer table roa_fail_v6;
      export filter {
        if ${community.LT_ROA_FAIL} ~ bgp_large_community then accept;
        reject;
      };
    };

    protocol pipe sys_roa_unknown_v6 {
      table master6;
      peer table roa_unknown_v6;
      export filter {
        if ${community.LT_ROA_UNKNOWN} ~ bgp_large_community then accept;
        reject;
      };
    };
  '';

  static =
    ''
      protocol device sys_device {
        scan time 10;
      }

      protocol static static_v4 {
        route 172.22.76.184/29 reject;
        route 172.22.76.96/27 reject;
        route 10.127.10.0/24 reject;

        # Workaround ghosting
        route 172.22.76.96/29 reject;
        route 172.22.76.104/29 reject;
        route 172.22.76.112/29 reject;
        route 172.22.76.120/29 reject;

        # Rerouted WAN addresses
        ${lib.optionalString (lib.hasInfix "azure" config.networking.hostName) "route 168.63.129.16/32 reject;  # Azure private DNS server"}
    ''
    + (lib.optionalString (LT.this.hasTag LT.tags.server) ''
      # Blackhole routes for private ranges
      ${lib.concatMapStringsSep "\n" (t: "route ${t} reject;") LT.constants.reserved.IPv4}
    '')
    + ''
        ipv4 {
          preference 1000;
          import all;
          export none;
        };
      };

      protocol static static_v6 {
        route fdbc:f9dc:67ad::/48 reject;
        route fd10:127:10::/48 reject;
    ''
    + (lib.optionalString (LT.this.hasTag LT.tags.server) ''
      # Blackhole routes for private ranges
      ${lib.concatMapStringsSep "\n" (t: "route ${t} reject;") LT.constants.reserved.IPv6}
    '')
    + ''
        ipv6 {
          preference 1000;
          import all;
          export none;
        };
      }
    ''
    + (lib.optionalString (LT.this.hasTag LT.tags.dn42) ''
      protocol static static_aggregated_v4 {
        route 172.20.0.0/14 reject;
        route 172.31.0.0/16 reject;
        route 10.127.0.0/16 reject;

        ipv4 {
          preference 9999;
          import filter { bgp_large_community.add(${community.LT_POLICY_INTERNAL_AGGREGATED}); accept; };
          export none;
        };
      }

      protocol static static_aggregated_v6 {
        route fd00::/8 reject;
        route fd10:127::/32 reject;

        ipv6 {
          preference 9999;
          import filter { bgp_large_community.add(${community.LT_POLICY_INTERNAL_AGGREGATED}); accept; };
          export none;
        };
      }
    '');
}
