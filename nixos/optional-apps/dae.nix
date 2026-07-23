{
  LT,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.lantian.dae;
in
{
  imports = [ ../client-apps/v2ray.nix ];

  options.lantian.dae = {
    wanInterface = lib.mkOption {
      type = lib.types.str;
      default = "auto";
    };
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    cnAction = lib.mkOption {
      type = lib.types.str;
      default = "unblock_cn";
    };
    intlAction = lib.mkOption {
      type = lib.types.str;
      default = "must_direct";
    };
  };

  config = {
    sops.secrets.ss-unblock-cn.sopsFile = inputs.secrets + "/common/dae.yaml";

    services.dae = {
      enable = true;
      config = ''
        global {
          tproxy_port: 1
          tproxy_port_protect: true
          wan_interface: ${cfg.wanInterface}
          ${lib.optionalString (
            cfg.lanInterfaces != [ ]
          ) "lan_interface: ${builtins.concatStringsSep "," cfg.lanInterfaces}"}
          auto_config_kernel_parameter: false
          log_level: warn

          tcp_check_url: 'https://example.com'
          tcp_check_http_method: HEAD
          udp_check_dns: 'dns.google:53,8.8.8.8,2001:4860:4860::8888'
          check_interval: 600s
          check_tolerance: 50ms

          dial_mode: domain
          allow_insecure: false
          sniffing_timeout: 100ms

          tls_implementation: utls
          utls_imitate: firefox_auto

          mptcp: true
        }

        subscription {
          ss_unblock_cn: "file://cn.sub"
        }

        node {
          v2ray: "socks5://localhost:${LT.portStr.V2Ray.SocksClient}"
          zgocloud: "socks5://${LT.hosts.zgocloud.ltnet.IPv4}:${LT.portStr.V2Ray.SocksClient}"
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
            filter: name(v2ray)
            policy: fixed(0)
          }
          unblock_cn {
            filter: subtag(ss_unblock_cn)
            policy: min_moving_avg
          }
          zgocloud {
            filter: name(zgocloud)
            policy: fixed(0)
          }
        }

        routing {
          pname(NetworkManager) -> must_direct
          pname(v2ray) -> must_direct
          pname(xray) -> must_direct
          pname(zerotier-one) -> must_direct
          dip(224.0.0.0/3, 'ff00::/8') -> must_direct

          # Unblock CN
          pname(qqmusic) -> ${cfg.cnAction}
          domain(geosite:cn) && dport(80) -> ${cfg.cnAction}
          domain(geosite:cn) && dport(443) -> ${cfg.cnAction}
          dip(geoip:cn) && dport(80) -> ${cfg.cnAction}
          dip(geoip:cn) && dport(443) -> ${cfg.cnAction}

          domain(geosite:category-ads) -> block
          domain(geosite:category-ads-all) -> block
          domain(geosite:private) -> must_direct
          domain(geosite:cn) -> must_direct
          domain(geosite:category-games@cn) -> must_direct
          dip(geoip:private) -> must_direct
          dip(geoip:cn) -> must_direct

          # V2Ray also handles direct connections

          fallback: ${cfg.intlAction}
        }
      '';
    };

    systemd.services.dae = {
      after = [ "sops-install-secrets.service" ];
      requires = [ "sops-install-secrets.service" ];
      serviceConfig = {
        Type = "simple"; # Do not block boot on network online
        Restart = "on-failure";
        RestartSec = "5";

        LoadCredential = [
          "cn.sub:${config.sops.secrets.ss-unblock-cn.path}"
        ];
      };
    };
  };
}
