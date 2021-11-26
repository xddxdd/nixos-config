{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

  sanitizeHostname = builtins.replaceStrings [ "-" ] [ "_" ];

  birdConfDir = ../files/bird;

  filterNetwork = net: pkgs.lib.filterAttrs (n: v: v.peering.network == net);

  latencyToDN42Community = latency:
    if latency <= 3 then 1 else
    if latency <= 7 then 2 else
    if latency <= 20 then 3 else
    if latency <= 55 then 4 else
    if latency <= 148 then 5 else
    if latency <= 403 then 6 else
    if latency <= 1097 then 7 else
    if latency <= 2981 then 8 else
    9;

  typeToDN42Community = type:
    if type == "openvpn" then 33 else
    if type == "wireguard" then 34 else
    if type == "gre" then 31 else
    31;

  externalDN42Peer = n: v:
    let
      interfaceName = "${v.peering.network}-${n}";
      latency = builtins.toString (latencyToDN42Community v.latencyMs);
      crypto = builtins.toString (typeToDN42Community v.tunnel.type);
    in
    pkgs.lib.optionalString (v.addressing.peerIPv4 != null && !v.peering.mpbgp) ''
      protocol bgp ${sanitizeHostname interfaceName}_v4 from dnpeers {
        neighbor ${v.addressing.peerIPv4} as ${builtins.toString v.remoteASN};
        local ${v.addressing.myIPv4} as ${pkgs.lib.toUpper v.peering.network}_AS;
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
        local ${v.addressing.myIPv6} as ${pkgs.lib.toUpper v.peering.network}_AS;
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
        local ${v.addressing.myIPv6Subnet} as ${pkgs.lib.toUpper v.peering.network}_AS;
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
        local ${v.addressing.myIPv6LinkLocal} as ${pkgs.lib.toUpper v.peering.network}_AS;
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

  birdDN42PeersConf = pkgs.writeText "bird-dn42-peers.conf"
    (builtins.concatStringsSep "\n"
      (pkgs.lib.mapAttrsToList externalDN42Peer (filterNetwork "dn42" config.services.dn42)));

  ltnetBGPPeer = hostname: { ltnet, ... }:
    ''
      protocol bgp ltnet_${sanitizeHostname hostname} from lantian_internal {
        neighbor ${ltnet.IPv6} internal;
        ipv4 {
          extended next hop yes;
          import filter { ltnet_import_filter_v4(); };
          export filter { ltnet_export_filter_v4(); };
        };
        ipv6 {
          extended next hop yes;
          import filter { ltnet_import_filter_v6(); };
          export filter { ltnet_export_filter_v6(); };
        };
      };
    '';

  birdLtnetPeersConf = pkgs.writeText "bird-ltnet-peers.conf"
    (builtins.concatStringsSep "\n"
      (pkgs.lib.mapAttrsToList ltnetBGPPeer otherHosts));

  birdLocalConf = pkgs.writeText "bird-local.conf" ''
    define LTNET_IPv4 = ${thisHost.ltnet.IPv4};
    define LTNET_IPv6 = ${thisHost.ltnet.IPv6};
    define LTNET_AS = ${builtins.toString (4225470000 + thisHost.index)};

    define DN42_AS = 4242422547;
    define DN42_IPv4 = ${thisHost.dn42.IPv4};
    define DN42_IPv6 = ${thisHost.dn42.IPv6};
    define DN42_REGION = ${builtins.toString thisHost.dn42.region};

    define NEO_AS = 4201270010;
    define NEO_IPv4 = ${thisHost.neonetwork.IPv4};
    define NEO_IPv6 = ${thisHost.neonetwork.IPv6};
  '';

in
{
  services.bird2 = {
    enable = true;
    checkConfig = false;
    config = ''
      include "${birdLocalConf}";
      include "${birdConfDir}/network.conf";
      include "${birdConfDir}/common/dn42_community_filters.conf";
      include "${birdConfDir}/common/ltnet_community.conf";
      include "${birdConfDir}/common/roa_monitor.conf";

      log stderr { warning, error, fatal };
      #debug protocols all;

      protocol device sys_device {
        scan time 10;
      }

      protocol static static_v4 {
    '' + pkgs.lib.optionalString (!(builtins.hasAttr "alone" thisHost.ltnet && thisHost.ltnet.alone)) ''
      route 172.22.76.184/29 reject;
      route 172.22.76.96/27 reject;
      route 10.127.10.0/24 reject;

      route 172.22.76.96/29 reject;
      route 172.22.76.104/29 reject;
      route 172.22.76.112/29 reject;
      route 172.22.76.120/29 reject;

      route ${thisHost.dn42.IPv4}/32 reject;
      route ${thisHost.neonetwork.IPv4}/32 reject;
    '' + ''
        # Blackhole routes for private ranges
        route 10.0.0.0/8 reject;
        route 172.16.0.0/12 reject;
        route 192.168.0.0/16 reject;

        ipv4 {
          preference 10000;
          import all;
          export none;
        };
      };

      protocol static static_v6 {
    '' + pkgs.lib.optionalString (!(builtins.hasAttr "alone" thisHost.ltnet && thisHost.ltnet.alone)) ''
      route fdbc:f9dc:67ad::/48 reject;
      route fd10:127:10::/48 reject;

      route ${thisHost.dn42.IPv6}/128 reject;
      route ${thisHost.neonetwork.IPv6}/128 reject;
    '' + ''
        # Blackhole routes for private ranges
        route fc00::/7 reject;

        ipv6 {
          preference 10000;
          import all;
          export none;
        };
      }

      roa4 table roa_v4;
      roa6 table roa_v6;

      protocol static static_roa4 {
        roa4 {
          table roa_v4;
        };
        include "/var/lib/bird/dn42/dn42_bird2_roa4.conf";
        include "/var/lib/bird/neonetwork/neonetwork_bird2_roa4.conf";
      };

      protocol static static_roa6 {
        roa6 {
          table roa_v6;
        };
        include "/var/lib/bird/dn42/dn42_bird2_roa6.conf";
        include "/var/lib/bird/neonetwork/neonetwork_bird2_roa6.conf";
      };

      router id LTNET_IPv4;

      timeformat protocol iso long;

      include "${birdConfDir}/dn42_neo_base.conf";
      include "${birdDN42PeersConf}";

    '' + pkgs.lib.optionalString (builtins.hasAttr "burble_grc" thisHost.dn42 && thisHost.dn42.burble_grc) ''
      # GRC config must be below dn42 & neonetwork since it uses filters from them
      include "${birdConfDir}/dn42/burble_grc.conf";

    '' + ''
      include "${birdConfDir}/docker_babel.conf";
      #include "${birdConfDir}/docker_ospf.conf";
      include "${birdConfDir}/ltnet_bgp.conf";
      include "${birdLtnetPeersConf}";
      #include "${birdConfDir}/ltnet/ustc_blacklist.conf";

      filter sys_import_v4 {
        if net !~ RESERVED_IPv4 then reject;
        bgp_large_community.add((DN42_AS, LT_POLICY, LT_POLICY_NOEXPORT));
        accept;
      }

      filter sys_import_v6 {
        if net !~ RESERVED_IPv6 then reject;
        bgp_large_community.add((DN42_AS, LT_POLICY, LT_POLICY_NOEXPORT));
        accept;
      }

      filter sys_export_v4 {
        if (DN42_AS, LT_ROA_ERROR, LT_ROA_FAIL) ~ bgp_large_community then reject;
        if (DN42_AS, LT_ROA_ERROR, LT_ROA_UNKNOWN) ~ bgp_large_community then reject;
        if (DN42_AS, LT_POLICY, LT_POLICY_DROP) ~ bgp_large_community then dest = RTD_BLACKHOLE;
        if net ~ DN42_NET_IPv4 then krt_prefsrc = DN42_IPv4;
        if net ~ NEONETWORK_NET_IPv4 then krt_prefsrc = NEO_IPv4;
        accept;
      }

      filter sys_export_v6 {
        if (DN42_AS, LT_ROA_ERROR, LT_ROA_FAIL) ~ bgp_large_community then reject;
        if (DN42_AS, LT_ROA_ERROR, LT_ROA_UNKNOWN) ~ bgp_large_community then reject;
        if (DN42_AS, LT_POLICY, LT_POLICY_DROP) ~ bgp_large_community then dest = RTD_BLACKHOLE;
        if net ~ DN42_NET_IPv6 then krt_prefsrc = DN42_IPv6;
        if net ~ NEONETWORK_NET_IPv6 then krt_prefsrc = NEO_IPv6;
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
        #merge paths yes;
        metric 4242;
        ipv4 {
          preference 100;
          import filter sys_import_v4;
          export filter sys_export_v4;
        };
      };

      protocol kernel sys_kernel_v6 {
        scan time 20;
        learn;
        #merge paths yes;
        metric 4242;
        ipv6 {
          preference 100;
          import filter sys_import_v6;
          export filter sys_export_v6;
        };
      };
    '';
  };

  systemd.services.bird-lgproxy-go-v4 = {
    description = "Bird-lgproxy-go IPv4";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.traceroute ];
    environment = {
      BIRD_SOCKET = "/run/bird.ctl";
      BIRD6_SOCKET = "/run/bird.ctl";
      BIRDLG_LISTEN = "${thisHost.ltnet.IPv4}:8000";
    };
    unitConfig = {
      After = "bird2.service";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur.repos.xddxdd.bird-lgproxy-go}/bin/proxy";
    };
  };
  systemd.services.bird-lgproxy-go-v6 = {
    description = "Bird-lgproxy-go IPv6";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.traceroute ];
    environment = {
      BIRD_SOCKET = "/run/bird.ctl";
      BIRD6_SOCKET = "/run/bird.ctl";
      BIRDLG_LISTEN = "[${thisHost.ltnet.IPv6}]:8000";
    };
    unitConfig = {
      After = "bird2.service";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur.repos.xddxdd.bird-lgproxy-go}/bin/proxy";
    };
  };
}
