{ LT, lib, ... }:
let
  ztHosts = lib.filterAttrs (_n: v: v.zerotier != null) LT.hosts;
in
{
  imports = [ ./upstreamable.nix ];

  services.zerotierone.controller = {
    enable = true;
    port = 9994;
    networks = {
      "000001" = {
        name = "ltnet";
        multicastLimit = 256;

        routes =
          [
            { target = "198.18.0.0/24"; }
            { target = "fdbc:f9dc:67ad::/64"; }

            # Default routing to home router
            {
              target = "0.0.0.0/0";
              via = "198.18.0.203";
            }
            {
              target = "::/0";
              via = "fdbc:f9dc:67ad::203	";
            }
          ]
          ++ (lib.flatten (
            lib.mapAttrsToList (
              _n: v:
              let
                i = builtins.toString v.index;
              in
              [
                {
                  target = "198.18.${i}.0/24";
                  via = "198.18.0.${i}";
                }
                {
                  target = "198.19.${i}.0/24";
                  via = "198.18.0.${i}";
                }
                {
                  target = "fdbc:f9dc:67ad:${i}::/64";
                  via = "fdbc:f9dc:67ad::${i}";
                }
              ]
            ) ztHosts
          ));

        members = lib.mapAttrs' (
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
      };
    };
  };
}
