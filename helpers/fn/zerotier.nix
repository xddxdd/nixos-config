{
  constants,
  hosts,
  lib,
  inputs,
}:
let
  ztHosts = lib.filterAttrs (n: v: v.zerotier != null) hosts;
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
  hosts = ztMembers // additionalMembers;

  clientManagedIPv4Ranges = constants.dn42.IPv4 ++ constants.neonetwork.IPv4 ++ [ "198.18.0.0/15" ];
  clientManagedIPv6Ranges =
    constants.dn42.IPv6 ++ constants.neonetwork.IPv6 ++ [ "fdbc:f9dc:67ad::/48" ];
}
