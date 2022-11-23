{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;
in
{
  services.nginx.virtualHosts = {
    "whois.lantian.pub" = {
      listen = LT.nginx.listenHTTPS ++ LT.nginx.listenHTTP;
      serverAliases = [ "whois.lantian.dn42" "whois.lantian.neo" ];

      locations = {
        "/".extraConfig = ''
          proxy_pass http://unix:/run/nginx/whois-stage1.sock;
          proxy_set_header Host "stage1.whois.local";
          add_before_body /lantian-prepend;
        '';

        # Prepend isn't working now, not sure why
        "/lantian-prepend".extraConfig = ''
          internal;
          return 200 "% Lan Tian Nginx-based WHOIS Server\n% GET $request_uri:\n\n";
        '';
      };

      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.listenProxyProtocol
        + ''
        listen unix:/run/nginx/whois.sock plain proxy_protocol default_server;
      '';
    };

    "stage1.whois.local" = {
      extraConfig = ''
        listen unix:/run/nginx/whois-stage1.sock default_server;
      '';
      root = "/nix/persistent/sync-servers/ltnet-registry/dn42/data";
      locations = {
        "/".extraConfig = ''
          set_by_lua $uri_upper "return ngx.var.uri:upper()";
          set_by_lua $uri_lower "return ngx.var.uri:lower()";

          rewrite "^/([0-9]{1})$" /AS424242000$1 last;
          rewrite "^/([0-9]{2})$" /AS42424200$1 last;
          rewrite "^/([0-9]{3})$" /AS4242420$1 last;
          rewrite "^/([0-9]{4})$" /AS424242$1 last;
          rewrite "^/([0-9]+)$" /AS$1 last;
          rewrite "^/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$" /$1.$2.$3.$4/32 last;
          rewrite "^/([0-9a-fA-F:]+)$" /$1/128 last;

          try_files /aut-num$uri_upper
                    /inetnum$uri_upper
                    /inet6num$uri_upper
                    /person$uri_upper
                    /mntner$uri_upper
                    /schema$uri_upper
                    /organisation$uri_upper
                    /tinc-keyset$uri_upper
                    /tinc-key$uri_upper
                    /route-set$uri_upper
                    /as-block$uri_upper
                    /as-set$uri_upper
                    /dns$uri_lower
                    $uri
                    @fallback;
        '';

        "~* \"^/([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)/([0-9]+)$\"".extraConfig = ''
          set $ip $1;
          set $mask $2;

          content_by_lua_block {
            local lantian_whois = require "lantian_whois";

            local ip_target = lantian_whois.ipv4_find("inetnum", ngx.var.ip, ngx.var.mask)
            local ip_content = lantian_whois.file_read(ip_target)
            local route_target = lantian_whois.ipv4_find("route", ngx.var.ip, ngx.var.mask)
            local route_content = lantian_whois.file_read(route_target)

            if ip_content == nil then
              ngx.exec('@fallback')
            else
              ngx.print(ip_content)
              ngx.say("\n% Relevant route object:")
              if route_content then
                ngx.print(route_content)
              else
                ngx.say("% 404")
              end
            end
          }
        '';

        "~* \"^/([0-9a-fA-F:]+)/([0-9]+)$\"".extraConfig = ''
          set $ip $1;
          set $mask $2;

          content_by_lua_block {
            local lantian_whois = require "lantian_whois";

            local ip_target = lantian_whois.ipv6_find("inet6num", ngx.var.ip, ngx.var.mask)
            local ip_content = lantian_whois.file_read(ip_target)
            local route_target = lantian_whois.ipv6_find("route6", ngx.var.ip, ngx.var.mask)
            local route_content = lantian_whois.file_read(route_target)

            if ip_content == nil then
              ngx.exec('@fallback')
            else
              ngx.print(ip_content)
              ngx.say("\n% Relevant route object:")
              if route_content then
                ngx.print(route_content)
              else
                ngx.say("% 404")
              end
            end
          }
        '';

        "@fallback".extraConfig = ''
          internal;
          proxy_pass http://unix:/run/nginx/whois-stage2.sock;
          proxy_set_header Host "stage2.whois.local";
        '';
      };
    };

    "stage2.whois.local" = {
      extraConfig = ''
        listen unix:/run/nginx/whois-stage2.sock default_server;
      '';
      locations = {
        "/".extraConfig = ''
          rewrite "^/([0-9]+)$" /AS$1 last;
          rewrite "^/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$" /$1.$2.$3.$4/32 last;
          rewrite "^/([0-9a-fA-F:]+)$" /$1/128 last;
          return 200 "% Lan Tian Nginx-based WHOIS Server\n% GET $request_uri:\n% 404 Not Found\n";
        '';

        "~* \"^/[Aa][Ss]([0-9]+)$\"".extraConfig = ''
          set $asn $1;
          set_by_lua_block $backend {
            local lantian_nginx = require "lantian_nginx";
            return lantian_nginx.whois_asn_lookup(ngx.var.asn);
          }

          proxy_pass http://$backend:43/AS$1;
          proxy_http_version plain;
        '';

        "~* \"^/([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)/([0-9]+)$\"".extraConfig = ''
          set $ip $1;
          set_by_lua_block $backend {
            local lantian_nginx = require "lantian_nginx";
            return lantian_nginx.whois_ip_lookup(ngx.var.ip);
          }

          proxy_pass http://$backend:43/$ip;
          proxy_http_version plain;
        '';

        "~* \"^/([0-9a-fA-F:]+)/([0-9]+)$\"".extraConfig = ''
          set $ip $1;
          set_by_lua_block $backend {
            local lantian_nginx = require "lantian_nginx";
            return lantian_nginx.whois_ip_lookup(ngx.var.ip);
          }

          proxy_pass http://$backend:43/$ip;
          proxy_http_version plain;
        '';

        "~* \"^/(.*)-([a-zA-Z0-9]+)$\"".extraConfig = ''
          set_by_lua $query_upper "return ngx.var.uri:upper():sub(2)";
          set_by_lua_block $backend {
            local lantian_nginx = require "lantian_nginx";
            return lantian_nginx.whois_nic_handle_lookup(ngx.var.query_upper);
          }

          proxy_pass http://$backend:43/$query_upper;
          proxy_http_version plain;
        '';

        "~* \"^/(.*)\\.([a-zA-Z0-9]+)$\"".extraConfig = ''
          set_by_lua $query_lower "return ngx.var.uri:lower():sub(2)";
          set_by_lua_block $backend {
            local lantian_nginx = require "lantian_nginx";
            return lantian_nginx.whois_domain_lookup(ngx.var.query_lower);
          }

          proxy_pass http://$backend:43/$query_lower;
          proxy_http_version plain;
        '';
      };
    };
  };
}
