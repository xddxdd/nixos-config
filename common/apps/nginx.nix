{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  imports = [
    ./nginx-lua.nix
    ./nginx-vhosts.nix
    ./php-fpm.nix
  ];

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
        "8.8.8.8"
      ];
      ipv6 = false;
    };
    sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    commonHttpConfig = ''
      access_log /var/log/nginx/access.$server_name.log;
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

      proxy_buffer_size       128k;
      proxy_buffers           4 256k;
      proxy_busy_buffers_size 256k;

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

      map $server_addr $gopher_addr {
        default               gopher.lantian.pub;
        "~*^172\.22\."        gopher.lantian.dn42;
        "~*^10\.127\."        gopher.lantian.neo;
        "~*^fdbc:f9dc:67ad:"  gopher.lantian.dn42;
        "~*^fd10:127:10:"     gopher.lantian.neo;
      }

      port_in_redirect off;
      absolute_redirect off;
      server_name_in_redirect off;

      charset utf-8;

      lua_package_path '/etc/nginx/lua/?.lua;;';
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
  };

  services.oauth2_proxy = {
    enable = true;
    clientID = "oauth-proxy";
    clientSecret = "***REMOVED***";
    cookie = {
      expire = "24h";
      secret = "***REMOVED***";
    };
    email.domains = [ "*" ];
    httpAddress = "http://${thisHost.ltnet.IPv4Prefix}.1:14180";
    provider = "oidc";
    setXauthrequest = true;
    extraConfig = {
      oidc-issuer-url = "http://127.0.0.1";
      insecure-oidc-skip-issuer-verification = "true";
    };
  };
  users.users.oauth2_proxy.group = "oauth2_proxy";
  users.groups.oauth2_proxy = { };

  systemd.services.oauth2_proxy = {
    unitConfig = {
      After = pkgs.lib.mkForce "network.target nginx.service";
    };
  };
}
