{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  listenIP = "127.53.53.53";
in
{
  networking.nameservers = [ listenIP ];

  services.coredns = {
    enable = true;
    package = pkgs.lantianCustomized.coredns;

    config =
      let
        forwardToLtnet = zone: ''
          ${zone} {
            any
            bind ${listenIP}
            bufsize 1232
            loadbalance round_robin

            forward . 172.18.0.253 fdbc:f9dc:67ad:2547::53
            cache
          }
        '';
      in
      builtins.concatStringsSep "\n" (
        [
          ''
            . {
              any
              bind ${listenIP}
              bufsize 1232
              loadbalance round_robin

              forward . tls://45.90.28.0 tls://45.90.30.0 tls://2a07:a8c0::0 tls://2a07:a8c1::0 {
                tls_servername ${config.networking.hostName}-378897.dns.nextdns.io
              }
              cache
            }
          ''
        ]
        ++ (builtins.map forwardToLtnet
          (with LT.constants; (dn42Zones ++ neonetworkZones ++ openNICZones ++ emercoinZones ++ yggdrasilAlfisZones)))
        ++ [ "" ]
      );
  };
}
