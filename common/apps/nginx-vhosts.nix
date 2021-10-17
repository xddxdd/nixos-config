{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  makeSSL = acmeName:
    let
      acmeHost = pkgs.lib.elemAt (pkgs.lib.splitString "_" acmeName) 0;
    in
    ''
      ssl_certificate /var/lib/acme.sh/${acmeName}/fullchain.cer;
      ssl_certificate_key /var/lib/acme.sh/${acmeName}/${acmeHost}.key;
      ssl_stapling on;
      ssl_stapling_file /var/lib/acme.sh/${acmeName}/ocsp.resp;
    '';

  commonVhostConf = ssl: ''
    add_header X-Content-Type-Options 'nosniff';
    add_header X-Frame-Options 'SAMEORIGIN';
    add_header X-XSS-Protection '1; mode=block; report="https://lantian.report-uri.com/r/d/xss/enforce"';
    #add_header Access-Control-Allow-Origin '*';
    add_header LT-Latency $request_time;
    add_header Expect-CT 'max-age=31536000; report-uri="https://lantian.report-uri.com/r/d/ct/reportOnly"';
    add_header Expect-Staple 'max-age=31536000; report-uri="https://lantian.report-uri.com/r/d/staple/reportOnly"'; 
    add_header PICS-Label '(PICS-1.1 "http://www.rsac.org/ratingsv01.html" l r (n 0 s 0 v 0 l 0))(PICS-1.1 "http://www.icra.org/ratingsv02.html" l r (cz 1 lz 1 nz 1 vz 1 oz 1))(PICS-1.1 "http://www.classify.org/safesurf/" l r (SS~~000 1))(PICS-1.1 "http://www.weburbia.com/safe/ratings.htm" l r (s 0))'; 
    add_header Cache-Control 'private'; 
    add_header Referrer-Policy strict-origin-when-cross-origin;
    add_header Permissions-Policy 'interest-cohort=()';

    more_clear_headers 'X-Powered-By' 'X-Runtime' 'X-Version' 'X-AspNet-Version';
  '' + pkgs.lib.optionalString ssl ''
    add_header Alt-Svc 'h3=":443"; ma=86400';
    add_header Strict-Transport-Security 'max-age=31536000;includeSubDomains;preload';
  '';

  addCommonLocationConf = pkgs.lib.recursiveUpdate {
    "/generate_204".extraConfig = ''
      access_log off;
      return 204;
    '';

    "/autoindex.html".extraConfig = ''
      internal;
      root /etc/nginx;
    '';

    "/status".extraConfig = ''
      access_log off;
      stub_status on;
    '';

    "/ray" = {
      proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:13504";
      proxyWebsockets = true;
      extraConfig = ''
        access_log off;
        keepalive_timeout 1d;
      '' + locationProxyConf;
    };

    "/oauth2/" = {
      proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:14180";
      extraConfig = ''
        proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
      '' + locationProxyConf;
    };

    "/oauth2/auth" = {
      proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:14180";
      extraConfig = ''
        proxy_set_header Content-Length "";
        proxy_pass_request_body off;
      '' + locationProxyConf;
    };

    "~ .*\.php(\/.*)*$".extraConfig = locationPHPConf;
  };

  locationProxyConf = ''
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Host $host:443;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Scheme $scheme;
    proxy_set_header X-Original-URI $request_uri;

    proxy_read_timeout 1d;
    proxy_buffering off;
    proxy_request_buffering on;
    proxy_redirect off;
    chunked_transfer_encoding off;
  '';

  # OAuth must go before proxy_pass!
  locationOauthConf = ''
    auth_request /oauth2/auth;
    error_page 401 = /oauth2/start;

    # pass information via X-User and X-Email headers to backend,
    # requires running with --set-xauthrequest flag
    auth_request_set $user   $upstream_http_x_auth_request_user;
    auth_request_set $email  $upstream_http_x_auth_request_email;
    proxy_set_header X-User  $user;
    proxy_set_header X-Email $email;

    # if you enabled --pass-access-token, this will pass the token to the backend
    auth_request_set $token  $upstream_http_x_auth_request_access_token;
    proxy_set_header X-Access-Token $token;
  '';

  locationPHPConf = pkgs.lib.optionalString (config.lantian.enable-php) ''
    try_files $fastcgi_script_name =404;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    fastcgi_pass unix:${config.services.phpfpm.pools.www.socket};
    fastcgi_index index.php;

    fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param  QUERY_STRING       $query_string;
    fastcgi_param  REQUEST_METHOD     $request_method;
    fastcgi_param  CONTENT_TYPE       $content_type;
    fastcgi_param  CONTENT_LENGTH     $content_length;

    fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
    fastcgi_param  REQUEST_URI        $request_uri;
    fastcgi_param  DOCUMENT_URI       $document_uri;
    fastcgi_param  DOCUMENT_ROOT      $document_root;
    fastcgi_param  SERVER_PROTOCOL    $server_protocol;
    fastcgi_param  HTTPS              $https if_not_empty;

    fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
    fastcgi_param  SERVER_SOFTWARE    lantian;

    fastcgi_param  REMOTE_ADDR        $remote_addr;
    fastcgi_param  REMOTE_PORT        $remote_port;
    fastcgi_param  SERVER_ADDR        $server_addr;
    fastcgi_param  SERVER_PORT        443;
    fastcgi_param  SERVER_NAME        $server_name;

    fastcgi_param  SSL_CIPHER         $ssl_cipher;
    fastcgi_param  SSL_CIPHERS        $ssl_ciphers;
    fastcgi_param  SSL_CURVES         $ssl_curves;
    fastcgi_param  SSL_PROTOCOL       $ssl_protocol;

    # PHP only, required if PHP was built with --enable-force-cgi-redirect
    fastcgi_param  REDIRECT_STATUS    200;
  '';

  listenDefaultFlags = [
    "default_server"
    "fastopen=100"
    "reuseport"
    "deferred"
    "so_keepalive=600:10:6"
  ];

  listen443 = [
    { addr = "0.0.0.0"; port = 443; extraParameters = [ "ssl" "http2" ]; }
    { addr = "[::]"; port = 443; extraParameters = [ "ssl" "http2" ]; }
    { addr = "0.0.0.0"; port = 443; extraParameters = [ "http3" ]; }
    { addr = "[::]"; port = 443; extraParameters = [ "http3" ]; }
  ];

  listen80 = [
    { addr = "0.0.0.0"; port = 80; }
    { addr = "[::]"; port = 80; }
  ];

  listenPlain = port: [
    { addr = "0.0.0.0"; port = port; extraParameters = [ "plain" ] ++ listenDefaultFlags; }
    { addr = "[::]"; port = port; extraParameters = [ "plain" ] ++ listenDefaultFlags; }
  ];

  listenPlainProxyProtocol = port: [
    { addr = "${thisHost.ltnet.IPv4Prefix}.1"; port = port; extraParameters = [ "plain" "proxy_protocol" ] ++ listenDefaultFlags; }
    { addr = "[${thisHost.ltnet.IPv6Prefix}::1]"; port = port; extraParameters = [ "plain" "proxy_protocol" ] ++ listenDefaultFlags; }
  ];

  listenProxyProtocol = ''
    set_real_ip_from 127.0.0.0/8;
    set_real_ip_from 172.18.0.0/16;
    set_real_ip_from fe80::/16;
    set_real_ip_from fdbc:f9dc:67ad::/48;
    real_ip_header proxy_protocol;
  '';

  addConfLantianPub = pkgs.lib.recursiveUpdate {
    locations = addCommonLocationConf {
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

    root = "/srv/www/lantian.pub";
  };
in
{
  services.nginx.virtualHosts = {
    "localhost" = {
      listen = [
        { addr = "0.0.0.0"; port = 443; extraParameters = [ "ssl" "http2" ] ++ listenDefaultFlags; }
        { addr = "[::]"; port = 443; extraParameters = [ "ssl" "http2" ] ++ listenDefaultFlags; }
        { addr = "0.0.0.0"; port = 443; extraParameters = [ "default_server" "http3" "reuseport" ]; }
        { addr = "[::]"; port = 443; extraParameters = [ "default_server" "http3" "reuseport" ]; }
        { addr = "0.0.0.0"; port = 80; extraParameters = listenDefaultFlags; }
        { addr = "[::]"; port = 80; extraParameters = listenDefaultFlags; }
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
      listen = listen443 ++ listen80;
      serverAliases = pkgs.lib.mapAttrsToList (k: v: k + ".lantian.pub") hosts;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + makeSSL "lantian.pub_ecc"
      + commonVhostConf true;
    };
    "lantian.dn42" = addConfLantianPub {
      listen = listen443 ++ listen80;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + makeSSL "lantian.dn42_ecc"
      + commonVhostConf false;
    };
    "lantian.neo" = addConfLantianPub {
      listen = listen80;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + commonVhostConf false;
    };

    "www.lantian.pub" = {
      listen = listen443 ++ listen80;
      globalRedirect = "lantian.pub";
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };

    "gopher.lantian.pub" = {
      listen = listen443 ++ listen80 ++ listenPlain 70 ++ listenPlainProxyProtocol 13270;
      root = "/srv/www/lantian.pub";
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
      + makeSSL "lantian.pub_ecc"
      + commonVhostConf true
      + listenProxyProtocol;
    };

    "whois.lantian.pub" = {
      listen = listen443 ++ listen80 ++ listenPlain 43 ++ listenPlainProxyProtocol 13243;
      root = "/srv/cache/dn42-registry/data";
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

      extraConfig = makeSSL "lantian.pub_ecc"
        + listenProxyProtocol;
    };
    "whois.stage2.local" = {
      listen = listen80;
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

    "ci.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "soyoustart") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:13080";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };
    "ci-github.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "soyoustart") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:13081";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };
    "vault.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "soyoustart") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:8200";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };

    "asf.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "soyoustart") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/".extraConfig = locationOauthConf + ''
          proxy_pass http://${thisHost.ltnet.IPv4Prefix}.1:13242;
        '' + locationProxyConf;
        "~* /Api/NLog".extraConfig = locationOauthConf + ''
          proxy_pass http://${thisHost.ltnet.IPv4Prefix}.1:13242;
          proxy_http_version 1.1;
          proxy_set_header Connection "upgrade";
          proxy_set_header Upgrade $http_upgrade;
        '' + locationProxyConf;
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };

    "login.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "virmach-ny6g") {
      listen = listen443;
      locations = addCommonLocationConf {
        "= /".return = "302 /auth/admin/";
        "/" = {
          proxyPass = "http://127.0.0.1:13401";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };

    "lg.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "virmach-ny6g") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:13180";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };
    "lg.lantian.dn42" = pkgs.lib.mkIf (config.networking.hostName == "virmach-ny6g") {
      listen = listen80;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4Prefix}.1:13180";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.dn42_ecc"
        + commonVhostConf true;
    };

    "bitwarden.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "virmach-ny6g") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:13772";
          extraConfig = locationProxyConf;
        };
        "/notifications/hub" = {
          proxyPass = "http://127.0.0.1:13773";
          proxyWebsockets = true;
          extraConfig = locationProxyConf;
        };
        "/notifications/hub/negotiate" = {
          proxyPass = "http://127.0.0.1:13772";
          extraConfig = locationProxyConf;
        };
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };

    "git.lantian.pub" = pkgs.lib.mkIf (config.networking.hostName == "virmach-ny1g") {
      listen = listen443;
      locations = addCommonLocationConf {
        "/" = {
          proxyPass = "http://unix:/run/gitea/gitea.sock";
          extraConfig = locationProxyConf;
        };
        "= /user/login".return = "302 /user/oauth2/Keycloak";
      };
      extraConfig = makeSSL "lantian.pub_ecc"
        + commonVhostConf true;
    };
  };
}
