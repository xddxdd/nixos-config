{ lib, ... }:
{
  services.dae = {
    enable = true;
    config = ''
      global {
        tproxy_port: 1
        tproxy_port_protect: true
        wan_interface: auto
        auto_config_kernel_parameter: false

        tcp_check_url: 'http://cp.cloudflare.com,1.1.1.1,2606:4700:4700::1111'
        tcp_check_http_method: HEAD
        udp_check_dns: 'dns.google:53,8.8.8.8,2001:4860:4860::8888'
        check_interval: 30s
        check_tolerance: 50ms

        dial_mode: domain
        allow_insecure: false
        sniffing_timeout: 100ms

        tls_implementation: utls
        utls_imitate: firefox_auto
      }

      node {
        v2ray: "socks5://localhost:1080"
      }

      dns {
        upstream {
          alidns: 'https://dns.alidns.com:443'
          googledns: 'https://dns.google:443'
        }
        routing {
          request {
            qname(geosite:cn) -> alidns
            fallback: googledns
          }
          response {
            upstream(googledns) -> accept
            ip(geoip:private) && !qname(geosite:cn) -> googledns
            fallback: accept
          }
        }
      }

      group {
        proxy {
          policy: fixed(0)
        }
      }

      routing {
        pname(NetworkManager) -> must_direct
        pname(v2ray) -> must_direct
        pname(xray) -> must_direct
        dip(224.0.0.0/3, 'ff00::/8') -> direct
        dip(geoip:private) -> direct

        # V2Ray handles direct connections

        fallback: proxy
      }
    '';
  };

  systemd.services.dae.wantedBy = lib.mkForce [ ];
}
