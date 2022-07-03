{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix { }) dialRule enumerateList prefixZeros;

  natSettings = ''
    local_net=10.0.0.0/8
    local_net=172.16.0.0/12
    local_net=192.168.0.0/16
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}
  '';
in
rec {
  transports = ''
    [transport-ipv4-udp]
    type=transport
    protocol=udp
    bind=0.0.0.0:5060
    tos=cs3
    cos=3
    ${natSettings}

    [transport-ipv4-tcp]
    type=transport
    protocol=tcp
    bind=0.0.0.0:5060
    tos=cs3
    cos=3
    ${natSettings}

    [transport-ipv4-tls]
    type=transport
    protocol=tls
    bind=0.0.0.0:5061
    cert_file=${LT.nginx.getSSLCert "lantian.pub_ecc"}
    priv_key_file=${LT.nginx.getSSLKey "lantian.pub_ecc"}
    method=tlsv1_2
    tos=cs3
    cos=3
    ${natSettings}

    [transport-ipv6-udp]
    type=transport
    protocol=udp
    bind=[::]:5060
    tos=cs3
    cos=3
    ${natSettings}

    [transport-ipv6-tcp]
    type=transport
    protocol=tcp
    bind=[::]:5060
    tos=cs3
    cos=3
    ${natSettings}

    [transport-ipv6-tls]
    type=transport
    protocol=tls
    bind=[::]:5061
    cert_file=${LT.nginx.getSSLCert "lantian.pub_ecc"}
    priv_key_file=${LT.nginx.getSSLKey "lantian.pub_ecc"}
    method=tlsv1_2
    tos=cs3
    cos=3
    ${natSettings}
  '';
}
