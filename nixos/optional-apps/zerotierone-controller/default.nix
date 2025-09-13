{
  LT,
  lib,
  inputs,
  ...
}:
let
  ztHosts = lib.filterAttrs (n: v: v.zerotier != null) LT.hosts;
  ztMembers = lib.mapAttrs' (
    n: v:
    let
      i = builtins.toString v.index;
    in
    lib.nameValuePair v.zerotier {
      name = n;
      ipAssignments = [
        "198.18.0.${i}"
        "fdbc:f9dc:67ad::${i}"
      ];
      noAutoAssignIps = true;
    }
  ) ztHosts;

  defaultGatewayHost = LT.hosts.v-ps-sea;
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

  additionalHosts = import (inputs.secrets + "/zerotier-additional-hosts.nix");
  additionalMembers = builtins.listToAttrs (
    builtins.map (
      {
        name,
        index,
        zerotier,
      }:
      lib.nameValuePair zerotier {
        inherit name;
        ipAssignments = [
          "198.18.0.${builtins.toString index}"
          "fdbc:f9dc:67ad::${builtins.toString index}"
        ];
        noAutoAssignIps = true;
      }
    ) additionalHosts
  );
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
        multicastLimit = 0;
        routes = ztRoutes;
        members = ztMembers // additionalMembers;
      };
    };
  };
}
