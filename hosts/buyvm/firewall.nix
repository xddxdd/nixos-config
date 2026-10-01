{
  lib,
  LT,
  ...
}:
{
  # Forward wg-lantian port ranges from this host's public addresses to each
  # host's tnl-buyvm network namespace.
  lantian.firewall.presets.port-forward = {
    enable = true;
    forwards =
      lib.concatLists (
        lib.mapAttrsToList (
          n:
          {
            wg-lantian,
            index,
            ...
          }:
          [
            {
              destination = "public";
              ports = "${builtins.toString wg-lantian.forwardStart}-${builtins.toString wg-lantian.forwardStop}";
              targetIPv4 = "198.18.${builtins.toString index}.192";
              targetIPv6 = "fdbc:f9dc:67ad:${builtins.toString index}::192";
            }
          ]
        ) LT.hosts
      )
      ++ (lib.optionals (LT.this.public.IPv6Subnet != null) (
        lib.mapAttrsToList (n: v: {
          destination = "address";
          destinationIPv6 = [ "${LT.this.public.IPv6Subnet}${builtins.toString v.index}" ];
          targetIPv6 = "fdbc:f9dc:67ad:${builtins.toString v.index}::192";
        }) LT.hosts
      ));
  };
}
