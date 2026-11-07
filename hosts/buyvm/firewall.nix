{
  lib,
  LT,
  ...
}:
let
  forwards = lib.mapAttrsToList (
    n:
    { wg-lantian, index, ... }:
    {
      ports = "${builtins.toString wg-lantian.forwardStart}-${builtins.toString wg-lantian.forwardStop}";
      ipv4 = "198.18.${builtins.toString index}.192";
      ipv6 = "fdbc:f9dc:67ad:${builtins.toString index}::192";
    }
  ) LT.hosts;
in
{
  # Forward wg-lantian port ranges from this host's public addresses to each
  # host's tnl-buyvm network namespace.
  lantian.firewall.zones.WAN.tcpPorts = lib.listToAttrs (
    map (f: {
      name = f.ports;
      value = {
        type = "forward";
        inherit (f) ipv4 ipv6;
      };
    }) forwards
  );

  # The provider routes the whole IPv6 /48 to this host, so the per-host
  # subnet addresses are not local and need an explicit destination match.
  lantian.firewall.chains.NAT_PREROUTING.dnat = lib.optionals (LT.this.public.IPv6Subnet != null) (
    lib.mapAttrsToList (n: v: {
      priority = LT.firewallPriorities.early;
      matches = [ "ip6 daddr ${LT.this.public.IPv6Subnet}${builtins.toString v.index}" ];
      ipv6 = "[fdbc:f9dc:67ad:${builtins.toString v.index}::192]";
    }) LT.hosts
  );
}
