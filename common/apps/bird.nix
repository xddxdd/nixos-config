{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  services.bird2 = {
    enable = true;
    checkConfig = false;
    config = ''
      include "/etc/bird/local.conf";
      include "/etc/bird/network.conf";
      include "/etc/bird/common/dn42_community_filters.conf";
      include "/etc/bird/common/ltnet_community.conf";
      include "/etc/bird/common/roa_monitor.conf";

      log stderr { error, fatal };
      #debug protocols all;

      protocol device sys_device {
        scan time 10;
      }

      protocol static static_v4 {
    '' + pkgs.lib.optionalString (builtins.hasAttr "alone" thisHost.ltnet && thisHost.ltnet.alone) (''
        route 172.22.76.184/29 reject;
        route 172.22.76.96/27 reject;
        route 10.127.10.0/24 reject;

        route 172.22.76.96/29 reject;
        route 172.22.76.104/29 reject;
        route 172.22.76.112/29 reject;
        route 172.22.76.120/29 reject;

        route ${thisHost.dn42.IPv4}/32 reject;
        route ${thisHost.neonetwork.IPv4}/32 reject;
    '') + ''
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
    '' + pkgs.lib.optionalString (builtins.hasAttr "alone" thisHost.ltnet && thisHost.ltnet.alone) (''
        route fdbc:f9dc:67ad::/48 reject;
        route fd10:127:10::/48 reject;

        route ${thisHost.dn42.IPv6}/128 reject;
        route ${thisHost.neonetwork.IPv6}/128 reject;
    '') + ''
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
        # include "/etc/bird/dn42/dn42_bird2_roa4.conf";
        # include "/etc/bird/neonetwork/neonetwork_bird2_roa4.conf";
      };

      protocol static static_roa6 {
        roa6 {
          table roa_v6;
        };
        # include "/etc/bird/dn42/dn42_bird2_roa6.conf";
        # include "/etc/bird/neonetwork/neonetwork_bird2_roa6.conf";
      };

      router id LTNET_IPv4;

      timeformat protocol iso long;

      include "/etc/bird/dn42/base.conf";
      include "/etc/bird/neonetwork/base.conf";

      # GRC config must be below dn42 & neonetwork since it uses filters from them
    '' + pkgs.lib.optionalString (builtins.hasAttr "burble_grc" thisHost.dn42 && thisHost.dn42.burble_grc) (''
      include "/etc/bird/dn42/burble_grc.conf";
    '') + ''

      include "/etc/bird/docker/ospf.conf";
      include "/etc/bird/ltnet/bgp.conf";
      include "/etc/bird/ltnet/bgp_downstream.conf";
      include "/etc/bird/ltnet/bgp_peers.conf";
      #include "/etc/bird/ltnet/ustc_blacklist.conf";

      protocol direct sys_direct {
        interface "*";
        ipv4 {
          preference 1000;
          import filter {
            if net !~ LTNET_IPv4_INT && net !~ LTNET_IPv4_NET && net !~ LTNET_IPv4_ANYCAST then reject;
            bgp_large_community.add((DN42_AS, LT_POLICY, LT_POLICY_NOEXPORT));
            accept;
          };
          export none;
        };
        ipv6 {
          preference 1000;
          import filter {
            if net !~ LTNET_IPv6_INT && net !~ LTNET_IPv6_NET && net !~ LTNET_IPv6_ANYCAST then reject;
            bgp_large_community.add((DN42_AS, LT_POLICY, LT_POLICY_NOEXPORT));
            accept;
          };
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
          import filter {
            if net !~ LTNET_IPv4_INT && net !~ LTNET_IPv4_NET && net !~ LTNET_IPv4_ANYCAST then reject;
            bgp_large_community.add((DN42_AS, LT_POLICY, LT_POLICY_NOEXPORT));
            accept;
          };
          export filter {
            if (DN42_AS, LT_ROA_ERROR, LT_ROA_FAIL) ~ bgp_large_community then reject;
            if (DN42_AS, LT_ROA_ERROR, LT_ROA_UNKNOWN) ~ bgp_large_community then reject;
            if (DN42_AS, LT_POLICY, LT_POLICY_DROP) ~ bgp_large_community then dest = RTD_BLACKHOLE;
            if net ~ DN42_NET_IPv4 then krt_prefsrc = DN42_IPv4;
            if net ~ NEONETWORK_NET_IPv4 then krt_prefsrc = NEONETWORK_IPv4;
            accept;
          };
        };
      };

      protocol kernel sys_kernel_v6 {
        scan time 20;
        learn;
        #merge paths yes;
        metric 4242;
        ipv6 {
          preference 100;
          import filter {
            if net !~ LTNET_IPv6_INT && net !~ LTNET_IPv6_NET && net !~ LTNET_IPv6_ANYCAST then reject;
            bgp_large_community.add((DN42_AS, LT_POLICY, LT_POLICY_NOEXPORT));
            accept;
          };
          export filter {
            if (DN42_AS, LT_ROA_ERROR, LT_ROA_FAIL) ~ bgp_large_community then reject;
            if (DN42_AS, LT_ROA_ERROR, LT_ROA_UNKNOWN) ~ bgp_large_community then reject;
            if (DN42_AS, LT_POLICY, LT_POLICY_DROP) ~ bgp_large_community then dest = RTD_BLACKHOLE;
            if net ~ DN42_NET_IPv6 then krt_prefsrc = DN42_IPv6;
            if net ~ NEONETWORK_NET_IPv6 then krt_prefsrc = NEONETWORK_IPv6;
            accept;
          };
        };
      };
    '';
  };

  environment.etc = {
    "bird/local.conf".text = ''
      define LTNET_IPv4 = ${thisHost.ltnet.IPv4Prefix}.1;
      define LTNET_IPv6 = ${thisHost.ltnet.IPv6Prefix}::1;
      define LTNET_AS = ${builtins.toString (4225470000 + thisHost.index)};

      define DN42_AS = 4242422547;
      define DN42_IPv4 = ${thisHost.dn42.IPv4};
      define DN42_IPv6 = ${thisHost.dn42.IPv6};
      define DN42_REGION = ${builtins.toString thisHost.dn42.region};

      define NEONETWORK_AS = 4201270010;
      define NEONETWORK_IPv4 = ${thisHost.neonetwork.IPv4};
      define NEONETWORK_IPv6 = ${thisHost.neonetwork.IPv6};
    '';

    "bird/network.conf".source = ../files/bird/network.conf;
    "bird/common/dn42_community_filters.conf".source = ../files/bird/common/dn42_community_filters.conf;
    "bird/common/ltnet_community.conf".source = ../files/bird/common/ltnet_community.conf;
    "bird/common/roa_monitor.conf".source = ../files/bird/common/roa_monitor.conf;
    "bird/dn42/base.conf".source = ../files/bird/dn42/base.conf;
    "bird/dn42/burble_grc.conf".source = ../files/bird/dn42/burble_grc.conf;
    "bird/docker/ospf.conf".source = ../files/bird/docker/ospf.conf;
    "bird/ltnet/bgp.conf".source = ../files/bird/ltnet/bgp.conf;
    "bird/ltnet/bgp_downstream.conf".source = ../files/bird/ltnet/bgp_downstream.conf;
    "bird/neonetwork/base.conf".source = ../files/bird/neonetwork/base.conf;

    "bird/dn42/peers4.conf".text = "# TODO";
    "bird/dn42/peers6.conf".text = "# TODO";
    "bird/ltnet/bgp_peers.conf".text = "# TODO";
    "bird/neonetwork/peers.conf".text = "# TODO";
  };
}
