{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };

  addConfLantianPub = pkgs.lib.recursiveUpdate {
    locations = nginxHelper.addCommonLocationConf {
      "/" = {
        index = "index.html index.htm";
      };
      "/assets/".extraConfig = ''
        expires 31536000;
      '';
      "/usr/" = {
        tryFiles = "$uri$avif_suffix$webp_suffix $uri$avif_suffix $uri$webp_suffix $uri =404";
        extraConfig = ''
          expires 31536000;
          add_header Vary "Accept";
          add_header Cache-Control "public, no-transform";
        '';
      };
      "= /favicon.ico".extraConfig = ''
        expires 31536000;
      '';
      "/feed".tryFiles = "$uri /feed.xml /atom.xml =404";
    };

    root = "/var/www/lantian.pub";
  };
in
{
  services.nginx.virtualHosts = {
    "localhost" = {
      listen = [
        { addr = "0.0.0.0"; port = 443; extraParameters = [ "ssl" "http2" ] ++ nginxHelper.listenDefaultFlags; }
        { addr = "[::]"; port = 443; extraParameters = [ "ssl" "http2" ] ++ nginxHelper.listenDefaultFlags; }
        { addr = "0.0.0.0"; port = 443; extraParameters = [ "default_server" "http3" "reuseport" ]; }
        { addr = "[::]"; port = 443; extraParameters = [ "default_server" "http3" "reuseport" ]; }
        { addr = "0.0.0.0"; port = 80; extraParameters = nginxHelper.listenDefaultFlags; }
        { addr = "[::]"; port = 80; extraParameters = nginxHelper.listenDefaultFlags; }
      ];

      locations = {
        "/".return = "444";
        "= /.well-known/openid-configuration".extraConfig = ''
          root ${../files/openid-configuration};
          try_files /openid-configuration =404;
        '';
        "= /openid-configuration".extraConfig = ''
          root ${../files/openid-configuration};
          try_files /openid-configuration =404;
        '';
        "/generate_204".return = "204";
      };

      rejectSSL = true;

      extraConfig = ''
        access_log off;
        ssl_stapling off;
      '';
    };

    "lantian.pub" = addConfLantianPub {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      serverAliases = pkgs.lib.mapAttrsToList (k: v: k + ".lantian.pub") hosts;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true;
    };
    "lantian.dn42" = addConfLantianPub {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + nginxHelper.makeSSL "lantian.dn42_ecc"
      + nginxHelper.commonVhostConf false;
    };
    "lantian.neo" = addConfLantianPub {
      listen = nginxHelper.listen80;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + nginxHelper.commonVhostConf false;
    };

    "www.lantian.pub" = {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      globalRedirect = "lantian.pub";
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };

    "gopher.lantian.pub" = {
      listen = nginxHelper.listen443
        ++ nginxHelper.listen80
        ++ nginxHelper.listenPlain 70
        ++ nginxHelper.listenPlainProxyProtocol 13270;
      root = "/var/www/lantian.pub";
      serverAliases = [ "gopher.lantian.dn42" "gopher.lantian.neo" ];

      locations."/" = {
        index = "gophermap";
        extraConfig = ''
          sub_filter "{{server_addr}}\t{{server_port}}" "$gopher_addr\t$server_port";
          sub_filter_once off;
          sub_filter_types '*';
        '';
      };

      extraConfig = ''
        error_page 404 /404.gopher;
      ''
      + nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.listenProxyProtocol;
    };

    "whois.lantian.pub" = {
      listen = nginxHelper.listen443
        ++ nginxHelper.listen80
        ++ nginxHelper.listenPlain 43
        ++ nginxHelper.listenPlainProxyProtocol 13243;
      root = "/var/cache/dn42-registry/data";
      serverAliases = [ "whois.lantian.dn42" "whois.lantian.neo" ];

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
          add_before_body /lantian-prepend;
        '';

        "~* \"^/([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)/([0-9]+)$\"".extraConfig = ''
          set $ip $1;
          set $mask $2;

          set_by_lua_block $path {
            local lantian_whois = require "lantian_whois";
            return lantian_whois.ipv4_find("inetnum", ngx.var.ip, ngx.var.mask)
          }

          try_files $path $uri @fallback;
        '';

        "~* \"^/([0-9a-fA-F:]+)/([0-9]+)$\"".extraConfig = ''
          set $ip $1;
          set $mask $2;

          set_by_lua_block $path {
            local lantian_whois = require "lantian_whois";
            return lantian_whois.ipv6_find("inet6num", ngx.var.ip, ngx.var.mask)
          }

          try_files $path $uri @fallback;
        '';

        "= /lantian-prepend".extraConfig = ''
          internal;
          return 200 "% Lan Tian Nginx-based WHOIS Server\n% GET $request_uri:\n";
        '';

        "@fallback".extraConfig = ''
          internal;
          proxy_pass http://127.0.0.1;
          proxy_set_header Host "whois.stage2.local";
        '';
      };

      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.listenProxyProtocol;
    };
    "whois.stage2.local" = {
      listen = nginxHelper.listen80;
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

        "~* \"^/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/([0-9]+)$\"".extraConfig = ''
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

        "~* \"^/(.*)\.([a-zA-Z0-9]+)$\"".extraConfig = ''
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

    "lab.lantian.pub" = pkgs.lib.mkIf (config.lantian.enable-lab) {
      listen = nginxHelper.listen443;
      root = "/var/www/lab.lantian.pub";
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          index = "index.php index.html index.htm";
          tryFiles = "$uri $uri/ =404";
        };
        "= /".extraConfig = ''
          autoindex on;
          add_after_body /autoindex.html;
        '';
        "/hobby-net".extraConfig = ''
          autoindex on;
          add_after_body /autoindex.html;
        '';
        "/zjui-ece385-scoreboard".extraConfig = ''
          gzip off;
          brotli off;
          zstd off;
        '';
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
  };
}
