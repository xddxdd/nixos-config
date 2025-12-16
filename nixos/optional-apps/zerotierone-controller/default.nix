{ LT, lib, ... }:
let
  defaultGatewayHost = LT.hosts.lt-home-vm;
  managedIPv4Ranges = LT.constants.dn42.IPv4 ++ LT.constants.neonetwork.IPv4 ++ [ "198.18.0.0/15" ];
  managedIPv6Ranges =
    LT.constants.dn42.IPv6 ++ LT.constants.neonetwork.IPv6 ++ [ "fdbc:f9dc:67ad::/48" ];

  ztRoutes = [
    { target = "198.18.0.0/24"; }
    { target = "fdbc:f9dc:67ad::/64"; }

    # Default routing to home router
    {
      target = "0.0.0.0/0";
      via = "198.18.0.204";
    }
    {
      target = "::/0";
      via = "fdbc:f9dc:67ad::204";
    }

    # SideStore
    {
      target = "10.7.0.1/32";
      via = defaultGatewayHost.ltnet.IPv4;
    }
  ]
  # Managed IP ranges
  ++ (builtins.map (r: {
    target = r;
    via = defaultGatewayHost.ltnet.IPv4;
  }) managedIPv4Ranges)
  ++ (builtins.map (r: {
    target = r;
    via = defaultGatewayHost.ltnet.IPv6;
  }) managedIPv6Ranges);
in
{
  imports = [ ./upstreamable.nix ];

  services.zerotierone.controller = {
    enable = true;
    port = 9994;
    networks = {
      "000001" = {
        name = "ltnet";
        mtu = 1400;
        multicastLimit = 256;
        routes = ztRoutes;
        members = LT.zerotier.hosts;
        relays = lib.mapAttrsToList (n: v: v.zerotier) (LT.hostsWithTag LT.tags.server);
      };
    };
  };
}
