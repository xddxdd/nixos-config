{ LT, lib, ... }:
let
  localNets = lib.concatMapStringsSep "\n" (ip: "local_net=${ip}") (
    LT.constants.reserved.IPv4 ++ LT.constants.reserved.IPv6
  );
in
{
  transports = ''
    [template-transport-common](!)
    type=transport
    tos=cs3
    cos=3
    ${localNets}

    ; Internet
    [transport-ipv4-udp](template-transport-common)
    protocol=udp
    bind=${LT.this.public.IPv4}:5060
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}

    [transport-ipv4-tcp](template-transport-common)
    protocol=tcp
    bind=${LT.this.public.IPv4}:5060
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}

    [transport-ipv4-tls](template-transport-common)
    protocol=tls
    bind=${LT.this.public.IPv4}:5061
    ca_list_file=/etc/ssl/certs/ca-certificates.crt
    cert_file=${LT.nginx.getSSLCert "zerossl-lantian.pub-ecc"}
    priv_key_file=${LT.nginx.getSSLKey "zerossl-lantian.pub-ecc"}
    method=tlsv1_2
    verify_client=no
    verify_server=yes
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}

    [transport-ipv6-udp](template-transport-common)
    protocol=udp
    bind=[${LT.this.public.IPv6}]:5060
    external_media_address=${LT.this.public.IPv6}
    external_signaling_address=${LT.this.public.IPv6}

    [transport-ipv6-tcp](template-transport-common)
    protocol=tcp
    bind=[${LT.this.public.IPv6}]:5060
    external_media_address=${LT.this.public.IPv6}
    external_signaling_address=${LT.this.public.IPv6}

    [transport-ipv6-tls](template-transport-common)
    protocol=tls
    bind=[${LT.this.public.IPv6}]:5061
    ca_list_file=/etc/ssl/certs/ca-certificates.crt
    cert_file=${LT.nginx.getSSLCert "zerossl-lantian.pub-ecc"}
    priv_key_file=${LT.nginx.getSSLKey "zerossl-lantian.pub-ecc"}
    method=tlsv1_2
    verify_client=no
    verify_server=yes
    external_media_address=${LT.this.public.IPv6}
    external_signaling_address=${LT.this.public.IPv6}

    ; DN42
    [transport-ipv4-udp-dn42](template-transport-common)
    protocol=udp
    bind=${LT.this.dn42.IPv4}:5060
    external_media_address=${LT.this.dn42.IPv4}
    external_signaling_address=${LT.this.dn42.IPv4}

    ; DN42, LTNET here is not a typo
    [transport-ipv6-udp-dn42](template-transport-common)
    protocol=udp
    bind=[${LT.this.ltnet.IPv6}]:5060
    external_media_address=${LT.this.ltnet.IPv6}
    external_signaling_address=${LT.this.ltnet.IPv6}
  '';
}
