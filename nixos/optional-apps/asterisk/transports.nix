{ LT, ... }:
rec {
  transports = ''
    [template-transport-common](!)
    type=transport
    tos=cs3
    cos=3
    local_net=10.0.0.0/8
    local_net=172.16.0.0/12
    local_net=192.168.0.0/16

    [transport-ipv4-udp](template-transport-common)
    protocol=udp
    bind=0.0.0.0:5060
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}

    [transport-ipv4-tcp](template-transport-common)
    protocol=tcp
    bind=0.0.0.0:5060
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}

    [transport-ipv4-tls](template-transport-common)
    protocol=tls
    bind=0.0.0.0:5061
    ca_list_file=/etc/ssl/certs/ca-certificates.crt
    cert_file=${LT.nginx.getSSLCert "lantian.pub_ecc"}
    priv_key_file=${LT.nginx.getSSLKey "lantian.pub_ecc"}
    method=tlsv1_2
    verify_client=no
    verify_server=yes
    external_media_address=${LT.this.public.IPv4}
    external_signaling_address=${LT.this.public.IPv4}

    [transport-ipv6-udp](template-transport-common)
    protocol=udp
    bind=[::]:5060
    external_media_address=${LT.this.public.IPv6}
    external_signaling_address=${LT.this.public.IPv6}

    [transport-ipv6-tcp](template-transport-common)
    protocol=tcp
    bind=[::]:5060
    external_media_address=${LT.this.public.IPv6}
    external_signaling_address=${LT.this.public.IPv6}

    [transport-ipv6-tls](template-transport-common)
    protocol=tls
    bind=[::]:5061
    ca_list_file=/etc/ssl/certs/ca-certificates.crt
    cert_file=${LT.nginx.getSSLCert "lantian.pub_ecc"}
    priv_key_file=${LT.nginx.getSSLKey "lantian.pub_ecc"}
    method=tlsv1_2
    verify_client=no
    verify_server=yes
    external_media_address=${LT.this.public.IPv6}
    external_signaling_address=${LT.this.public.IPv6}
  '';
}
