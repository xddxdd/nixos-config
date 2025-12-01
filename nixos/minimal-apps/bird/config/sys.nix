{
  lib,
  LT,
  ...
}@args:
let
  inherit (import ./common.nix args) community DN42_AS;

  commonStaticRoutesIPv4 = [
    "172.22.76.184/29"
    "172.22.76.96/27"
    "10.127.10.0/24"
  ];

  commonStaticRoutesIPv6 = [
    "fdbc:f9dc:67ad::/48"
    "fd10:127:10::/48"
  ];
in
{
  common = ''
    log stderr { warning, error, fatal };
    router id ${if LT.this.dn42.IPv4 != null then LT.this.dn42.IPv4 else LT.this.ltnet.IPv4};
    timeformat protocol iso long;
    #debug protocols all;

    flow4 table master_flow4;
    flow6 table master_flow6;
  '';

  flap-block = ''
    include "/var/cache/bird/flap-block.conf";
  '';

  kernel = ''
    filter sys_import_v4 {
      if net !~ RESERVED_IPv4 then reject;
      if net !~ LTNET_IPv4 && net.len = 32 then reject;
      bgp_community.add(${community.NO_EXPORT});
      accept;
    }

    filter sys_import_v6 {
      if net !~ RESERVED_IPv6 then reject;
      if net !~ LTNET_IPv6 && net.len = 128 then reject;
      bgp_community.add(${community.NO_EXPORT});
      accept;
    }

    filter sys_export_v4 {
      if net ~ LTNET_UNMANAGED_IPv4 then reject;
      if ${community.LT_POLICY_NO_KERNEL} ~ bgp_large_community then reject;

      krt_metric = 4242;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then {
        krt_metric = 65535;
        if net ~ REROUTED_IPv4 then reject;
      }

      krt_prefsrc = ${LT.this.ltnet.IPv4};
      ${lib.optionalString (
        LT.this.dn42.IPv4 != null
      ) "if net ~ DN42_NET_IPv4 then krt_prefsrc = ${LT.this.dn42.IPv4};"}
      ${lib.optionalString (
        LT.this.neonetwork.IPv4 != null
      ) "if net ~ NEONETWORK_NET_IPv4 then krt_prefsrc = ${LT.this.neonetwork.IPv4};"}

      accept;
    }

    filter sys_export_v6 {
      if net ~ LTNET_UNMANAGED_IPv6 then reject;
      if ${community.LT_POLICY_NO_KERNEL} ~ bgp_large_community then reject;

      krt_metric = 4242;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then {
        krt_metric = 65535;
        if net ~ REROUTED_IPv6 then reject;
      }

      krt_prefsrc = ${LT.this.ltnet.IPv6};
      ${lib.optionalString (
        LT.this.dn42.IPv6 != null
      ) "if net ~ DN42_NET_IPv6 then krt_prefsrc = ${LT.this.dn42.IPv6};"}
      ${lib.optionalString (
        LT.this.neonetwork.IPv6 != null
      ) "if net ~ NEONETWORK_NET_IPv6 then krt_prefsrc = ${LT.this.neonetwork.IPv6};"}

      accept;
    }

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
      192.168.0.0/16+
    ];

    # IP ranges managed by other networking tools
    define LTNET_UNMANAGED_IPv6 = [
      fc00:192:168::/48+
    ];

    define NEONETWORK_NET_IPv4 = [
      10.127.0.0/16+
    ];

    define NEONETWORK_NET_IPv6 = [
      fd10:127::/32+
    ];

    define REROUTED_IPv4 = [
    ${builtins.concatStringsSep ",\n" (
      builtins.filter (v: !lib.hasInfix ":" v) (
        lib.unique (lib.flatten (lib.mapAttrsToList (n: v: v.additionalRoutes) LT.hosts))
      )
    )}
    ];

    define REROUTED_IPv6 = [
    ${builtins.concatStringsSep ",\n" (
      builtins.filter (v: lib.hasInfix ":" v) (
        lib.unique (lib.flatten (lib.mapAttrsToList (n: v: v.additionalRoutes) LT.hosts))
      )
    )}
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

  static = ''
    protocol device sys_device {
      scan time 10;
    }

    protocol static static_v4 {
      # Common static routes
      ${lib.concatMapStringsSep "\n" (t: "route ${t} reject;") commonStaticRoutesIPv4}

      # Host specific routes
      ${lib.concatMapStringsSep "\n" (t: ''
        route ${t} reject {
          bgp_community.add(${community.NO_EXPORT});
        };
      '') LT.this._routes4}

      # Blackhole routes for private ranges
      ${lib.concatMapStringsSep "\n" (t: ''
        route ${t} reject {
          bgp_community.add(${community.NO_ADVERTISE});
        };
      '') LT.constants.reserved.IPv4}

      ipv4 {
        preference 1000;
        import all;
        export none;
      };
    };

    protocol static static_v6 {
      # Common static routes
      ${lib.concatMapStringsSep "\n" (t: "route ${t} reject;") commonStaticRoutesIPv6}

      # Host specific routes
      ${lib.concatMapStringsSep "\n" (t: ''
        route ${t} reject {
          bgp_community.add(${community.NO_EXPORT});
        };
      '') LT.this._routes6}

      # Blackhole routes for private ranges
      ${lib.concatMapStringsSep "\n" (t: ''
        route ${t} reject {
          bgp_community.add(${community.NO_ADVERTISE});
        };
      '') LT.constants.reserved.IPv6}

      ipv6 {
        preference 1000;
        import all;
        export none;
      };
    }
  '';

  flapAlerted = ''
    protocol bgp sys_flapalerted {
      local ${LT.this.dn42.IPv6} as ${DN42_AS};
      neighbor ${LT.hosts."colocrossing".ltnet.IPv6} as ${DN42_AS} port ${LT.portStr.FlapAlerted.BGP};

      # Send all routes for analysis
      interpret communities off;

      ipv4 {
        add paths on;
        export all;
        import none;
      };

      ipv6 {
        add paths on;
        export all;
        import none;
      };
    }
  '';

  flowspec = ''
    protocol bgp sys_flowspec {
      local ::1 as ${DN42_AS};
      neighbor ::1 port ${LT.portStr.Hack3ricFlow} as 65000;
      multihop 1;

      flow4 {
        table master_flow4;
        export all;
        import none;
      };
      flow6 {
        table master_flow6;
        export all;
        import none;
      };
    }
  '';
}
