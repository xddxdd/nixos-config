# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  makeSSL = acmeName:
    let
      acmeHost = pkgs.lib.elemAt (pkgs.lib.splitString "_" acmeName) 0;
    in
    ''
      ssl_stapling on;
      ssl_stapling_file /srv/data/acme.sh/${acmeName}/ocsp.resp;
    '';

  commonVhostConf = ''
    add_header X-Content-Type-Options 'nosniff';
    add_header X-Frame-Options 'SAMEORIGIN';
    add_header X-XSS-Protection '1; mode=block; report="https://lantian.report-uri.com/r/d/xss/enforce"';
    add_header Strict-Transport-Security 'max-age=31536000;includeSubDomains;preload';
    #add_header Access-Control-Allow-Origin '*';
    add_header LT-Latency $request_time;
    add_header Expect-CT 'max-age=31536000; report-uri="https://lantian.report-uri.com/r/d/ct/reportOnly"';
    add_header Expect-Staple 'max-age=31536000; report-uri="https://lantian.report-uri.com/r/d/staple/reportOnly"'; 
    add_header PICS-Label '(PICS-1.1 "http://www.rsac.org/ratingsv01.html" l r (n 0 s 0 v 0 l 0))(PICS-1.1 "http://www.icra.org/ratingsv02.html" l r (cz 1 lz 1 nz 1 vz 1 oz 1))(PICS-1.1 "http://www.classify.org/safesurf/" l r (SS~~000 1))(PICS-1.1 "http://www.weburbia.com/safe/ratings.htm" l r (s 0))'; 
    add_header Cache-Control 'private'; 
    add_header Referrer-Policy strict-origin-when-cross-origin;
    add_header Permissions-Policy 'interest-cohort=()';

    more_clear_headers 'X-Powered-By' 'X-Runtime' 'X-Version' 'X-AspNet-Version';
  '';

  commonLocationConf = {
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
      proxyPass = "http://127.0.0.1:13504";
      proxyWebsockets = true;
      extraConfig = ''
        access_log off;
        keepalive_timeout 1d;
      '';
    };
  };
in
{
  # Disable checking nginx.conf
  nixpkgs.overlays = [
    (final: prev:
      let
        awkFormatNginx = builtins.toFile "awkFormat-nginx.awk" ''
          awk -f
          {sub(/^[ \t]+/,"");idx=0}
          /\{/{ctx++;idx=1}
          /\}/{ctx--}
          {id="";for(i=idx;i<ctx;i++)id=sprintf("%s%s", id, "\t");printf "%s%s\n", id, $0}
        '';
      in
      {
        writers.writeNginxConfig = name: text: prev.runCommandLocal name
          {
            inherit text;
            passAsFile = [ "text" ];
            nativeBuildInputs = with pkgs; [ gawk gnused ];
          } ''
          awk -f ${awkFormatNginx} "$textPath" | sed '/^\s*$/d' > $out
        '';
      })
  ];

  services.nginx = {
    enable = true;
    enableReload = true;
    package = pkgs.nur.repos.xddxdd.openresty-lantian;
    proxyResolveWhileRunning = true;
    proxyTimeout = "1d";
    recommendedGzipSettings = false; # use my own
    recommendedOptimisation = true;
    recommendedProxySettings = false; # use my own
    recommendedTlsSettings = true;
    resolver = {
      addresses = [
        "1.1.1.1"
      ];
      ipv6 = false;
    };
    sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    commonHttpConfig = ''
      more_set_headers "Server: lantian";

      gzip on;
      gzip_disable "msie6";
      gzip_vary on;
      gzip_proxied any;
      gzip_comp_level 6;
      gzip_buffers 16 8k;
      gzip_http_version 1.0;
      gzip_types application/atom+xml application/geo+json application/javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/vnd.ms-fontobject application/wasm application/x-perl application/x-web-app-manifest+json application/xhtml+xml application/xml application/xspf+xml audio/midi font/otf image/bmp image/svg+xml text/cache-manifest text/calendar text/css text/javascript text/markdown text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy text/xml;
      gzip_static on;

      brotli on;
      brotli_types application/atom+xml application/geo+json application/javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/vnd.ms-fontobject application/wasm application/x-perl application/x-web-app-manifest+json application/xhtml+xml application/xml application/xspf+xml audio/midi font/otf image/bmp image/svg+xml text/cache-manifest text/calendar text/css text/javascript text/markdown text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy text/xml;
      brotli_buffers 16 8k;
      brotli_comp_level 6;
      brotli_static on;

      zstd off;
      zstd_comp_level 6;
      zstd_min_length 256;
      zstd_types application/atom+xml application/geo+json application/javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/vnd.ms-fontobject application/wasm application/x-perl application/x-web-app-manifest+json application/xhtml+xml application/xml application/xspf+xml audio/midi font/otf image/bmp image/svg+xml text/cache-manifest text/calendar text/css text/javascript text/markdown text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy text/xml;
      zstd_buffers 16 8k;
      zstd_static off;

      ssl_ecdh_curve 'p256_sidhp434:p256_sikep434:p256_frodo640aes:p256_bikel1:p256_ntru_hps2048509:p256_lightsaber:prime256v1:secp384r1:secp521r1';
      ssl_early_data on;
      ssl_dyn_rec_enable on;

      vhost_traffic_status on;
      vhost_traffic_status_zone;

      stream_server_traffic_status on;
      stream_server_traffic_status_zone;

      map $http_accept $webp_suffix {
        default "";
        "~image/webp" ".webp";
      }
      map $http_accept $avif_suffix {
        default "";
        "~image/avif" ".avif";
      }

      port_in_redirect off;
      absolute_redirect off;
      server_name_in_redirect off;

      charset utf-8;

      lua_package_path '/etc/nginx/conf/lua/?.lua;;';
    '';

    streamConfig = ''
      tcp_nodelay on;
      proxy_socket_keepalive on;

      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
      # Keep in sync with https://ssl-config.mozilla.org/#server=nginx&config=intermediate
      ssl_session_timeout 1d;
      ssl_session_cache shared:SSL_STREAM:10m;
      # Breaks forward secrecy: https://github.com/mozilla/server-side-tls/issues/135
      ssl_session_tickets off;
      # We don't enable insecure ciphers by default, so this allows
      # clients to pick the most performant, per https://github.com/mozilla/server-side-tls/issues/260
      ssl_prefer_server_ciphers off;
      ssl_ecdh_curve 'p256_sidhp434:p256_sikep434:p256_frodo640aes:p256_bike1l1cpa:p256_kyber90s512:p256_ntru_hps2048509:p256_lightsaber:prime256v1:secp384r1:secp521r1';

      server_traffic_status_zone;

      lua_package_path '/etc/nginx/conf/lua/?.lua;;';
    '';

    virtualHosts = {
      "lantian.pub" = {
        addSSL = true;
        http2 = true;
        http3 = true;

        locations = pkgs.lib.recursiveUpdate commonLocationConf {
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
          "/favicon.ico".extraConfig = ''
            expires 31536000;
          '';
          "/feed".tryFiles = "$uri /feed.xml /atom.xml =404";
        };

        root = "/srv/www/lantian.pub";

        serverAliases = pkgs.lib.mapAttrsToList (k: v: k + ".lantian.pub") hosts;

        sslCertificate = "/srv/data/acme.sh/lantian.pub_ecc/fullchain.cer";
        sslCertificateKey = "/srv/data/acme.sh/lantian.pub_ecc/lantian.pub.key";

        extraConfig = ''
          gzip off;
          gzip_static on;
          brotli off;
          brotli_static on;

          error_page 404 /404.html;
        ''
        + makeSSL "lantian.pub_ecc"
        + commonVhostConf;
      };
    };
  };
}
