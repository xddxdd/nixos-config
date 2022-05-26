{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  networking.nameservers = [ LT.constants.localDNSBindIP ];

  services.coredns = {
    enable = true;
    package = pkgs.lantianCustomized.coredns;

    config =
      let
        forwardToLtnet = zone: ''
          ${zone} {
            any
            bind ${LT.constants.localDNSBindIP}
            bufsize 1232
            loadbalance round_robin

            forward . 172.18.0.253 fdbc:f9dc:67ad:2547::53
            cache
          }
        '';
        forwardToGoogleDNS = zone: ''
          ${zone} {
            any
            bind ${LT.constants.localDNSBindIP}
            bufsize 1232
            loadbalance round_robin

            forward . 8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844 {
              tls_servername dns.google
            }
            cache
          }
        '';
      in
      builtins.concatStringsSep "\n" (
        [
          ''
            . {
              any
              bind ${LT.constants.localDNSBindIP}
              bufsize 1232
              loadbalance round_robin

              forward . tls://45.90.28.0 tls://45.90.30.0 tls://2a07:a8c0::0 tls://2a07:a8c1::0 {
                tls_servername ${config.networking.hostName}-378897.dns.nextdns.io
              }
              cache {
                success 32768 86400 3600
                denial 32768 86400 3600
              }
            }
          ''
        ]
        ++ (builtins.map forwardToGoogleDNS [
          "humio.com"
          "resilio.com"
          "syncthing.net"
        ])
        ++ (builtins.map forwardToLtnet
          (with LT.constants; (dn42Zones ++ neonetworkZones ++ openNICZones ++ emercoinZones ++ yggdrasilAlfisZones)))
        ++ [ "" ]
      );
  };
}
