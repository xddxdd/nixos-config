{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };
  inherit (import ./common.nix { inherit config pkgs lib; })
    DN42_AS DN42_REGION NEO_AS
    community sanitizeHostname;

  reservedIPv4 = [
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.0.0.0/24"
    "192.0.2.0/24"
    "192.168.0.0/16"
    "198.18.0.0/15"
    "198.51.100.0/24"
    "203.0.113.0/24"
    "240.0.0.0/4"
  ];

  reservedIPv6 = [
    "fc00::/7"
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
      bgp_large_community.add(${community.LT_POLICY_NO_EXPORT});
      accept;
    }

    filter sys_import_v6 {
      if net !~ RESERVED_IPv6 then reject;
      bgp_large_community.add(${community.LT_POLICY_NO_EXPORT});
      accept;
    }

    filter sys_export_v4 {
      if ${community.LT_POLICY_NO_KERNEL} ~ bgp_large_community then reject;
      if ${community.LT_POLICY_DROP} ~ bgp_large_community then dest = RTD_UNREACHABLE;

      krt_metric = 4242;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then krt_metric = 65535;

      krt_prefsrc = ${LT.this.ltnet.IPv4};
      ${lib.optionalString (LT.this.dn42.IPv4 != "") "if net ~ DN42_NET_IPv4 then krt_prefsrc = ${LT.this.dn42.IPv4};"}
      ${lib.optionalString (LT.this.neonetwork.IPv4 != "") "if net ~ NEONETWORK_NET_IPv4 then krt_prefsrc = ${LT.this.neonetwork.IPv4};"}

      accept;
    }

    filter sys_export_v6 {
      if ${community.LT_POLICY_NO_KERNEL} ~ bgp_large_community then reject;
      if ${community.LT_POLICY_DROP} ~ bgp_large_community then dest = RTD_UNREACHABLE;

      krt_metric = 4242;
      if dest ~ [RTD_BLACKHOLE, RTD_UNREACHABLE, RTD_PROHIBIT] then krt_metric = 65535;

      krt_prefsrc = ${LT.this.ltnet.IPv6};
      ${lib.optionalString (LT.this.dn42.IPv4 != "") "if net ~ DN42_NET_IPv6 then krt_prefsrc = ${LT.this.dn42.IPv6};"}
      ${lib.optionalString (LT.this.neonetwork.IPv4 != "") "if net ~ NEONETWORK_NET_IPv6 then krt_prefsrc = ${LT.this.neonetwork.IPv6};"}

      accept;
    }

    protocol direct sys_direct {
      interface "*";
      ipv4 {
        preference 1000;
        import filter sys_import_v4;
        export none;
      };
      ipv6 {
        preference 1000;
        import filter sys_import_v6;
        export none;
      };
    };

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
      172.18.0.0/16+,
      10.127.10.0/24+
    ];

    define LTNET_IPv6 = [
      fdbc:f9dc:67ad::/48+,
      fd10:127:10::/48
    ];

    define NEONETWORK_NET_IPv4 = [
      10.127.0.0/16+
    ];

    define NEONETWORK_NET_IPv6 = [
      fd10:127::/32+
    ];

    # Reserved range, where system is allowed to operate
    define RESERVED_IPv4 = [
    ${builtins.concatStringsSep ",\n"
      (builtins.map (t: t + "+") reservedIPv4)}
    ];

    define RESERVED_IPv6 = [
    ${builtins.concatStringsSep ",\n"
      (builtins.map (t: t + "+") reservedIPv6)}
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
  '' + lib.optionalString (!LT.this.ltnet.alone) ''
    route 172.22.76.184/29 reject;
    route 172.22.76.96/27 reject;
    route 10.127.10.0/24 reject;

    # Workaround ghosting
    route 172.22.76.96/29 reject;
    route 172.22.76.104/29 reject;
    route 172.22.76.112/29 reject;
    route 172.22.76.120/29 reject;

    route ${LT.this.dn42.IPv4}/32 reject;
    route ${LT.this.neonetwork.IPv4}/32 reject;

    # Blackhole routes for private ranges
    ${builtins.concatStringsSep "\n"
      (builtins.map (t: "route ${t} reject;") reservedIPv4)}
  '' + ''
      ipv4 {
        preference 10000;
        import all;
        export none;
      };
    };

    protocol static static_v6 {
  '' + lib.optionalString (!LT.this.ltnet.alone) ''
    route fdbc:f9dc:67ad::/48 reject;
    route fd10:127:10::/48 reject;

    route ${LT.this.dn42.IPv6}/128 reject;
    route ${LT.this.neonetwork.IPv6}/128 reject;

    # Blackhole routes for private ranges
    ${builtins.concatStringsSep "\n"
      (builtins.map (t: "route ${t} reject;") reservedIPv6)}
  '' + ''
      ipv6 {
        preference 10000;
        import all;
        export none;
      };
    }
  '';
}
