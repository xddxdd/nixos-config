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
  ztRoutes = [
    { target = "198.18.0.0/24"; }
    { target = "fdbc:f9dc:67ad::/64"; }

    # Default routing to home router
    {
      target = "0.0.0.0/0";
      via = "198.18.0.203";
    }
    {
      target = "::/0";
      via = "fdbc:f9dc:67ad::203";
    }
    # SideStore
    {
      target = "10.7.0.1/32";
      via = LT.hosts.hetzner-de.ltnet.IPv4;
    }
  ]
  ++ (lib.flatten (
    lib.mapAttrsToList (
      n: v:
      let
        i = builtins.toString v.index;
        routes = [
          "198.18.${i}.0/24"
          "198.19.${i}.0/24"
          "fdbc:f9dc:67ad:${i}::/64"
        ]
        ++ (lib.optionals (v.dn42.IPv4 != "") [ "${v.dn42.IPv4}/32" ])
        ++ (lib.optionals (v.neonetwork.IPv4 != "") [ "${v.neonetwork.IPv4}/32" ])
        ++ (lib.optionals (v.neonetwork.IPv6 != "") [ "${v.neonetwork.IPv6}/64" ])
        ++ v.additionalRoutes;
      in
      builtins.map (r: {
        target = r;
        via = if lib.hasInfix ":" r then "fdbc:f9dc:67ad::${i}" else "198.18.0.${i}";
      }) routes
    ) ztHosts
  ));

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
        multicastLimit = 256;
        routes = ztRoutes;
        members = ztMembers // additionalMembers;
      };
    };
  };
}
