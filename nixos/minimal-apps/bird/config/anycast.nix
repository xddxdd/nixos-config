{
  lib,
  LT,
  config,
  ...
}@args:
let
  inherit (import ./common.nix args) community;
in
{
  babel = ''
    filter anycast_v4 {
      if net.len != 32 then reject;
      bgp_community.add(${community.NO_EXPORT});
      accept;
    }

    filter anycast_v6 {
      if net.len != 128 then reject;
      bgp_community.add(${community.NO_EXPORT});
      accept;
    }

    protocol babel ltdocker {
      ipv4 {
        import keep filtered;
        import filter anycast_v4;
        export none;
      };
      ipv6 {
        import keep filtered;
        import filter anycast_v6;
        export none;
      };
      interface "ns-*" {
        type wired;
        hello interval 1s;
        update interval 1s;
        port 6695;
      };
      interface "ve-*" {
        type wired;
        hello interval 1s;
        update interval 1s;
        port 6695;
      };
    }
  '';
}
