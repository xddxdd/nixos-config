{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ./nginx-lua.nix
    ./nginx-vhosts.nix
    ./nginx-whois-server.nix
    ./php-fpm.nix
  ];

  age.secrets.oauth2-proxy-conf.file = pkgs.secrets + "/oauth2-proxy-conf.age";

  services.nginx = rec {
    enable = true;
    enableReload = true;
    package = pkgs.openresty-lantian;
    proxyResolveWhileRunning = true;
    proxyTimeout = "1d";
    recommendedGzipSettings = false; # use my own
    recommendedOptimisation = true;
    recommendedProxySettings = false; # use my own
    recommendedTlsSettings = false; # use my own
    resolver = {
      addresses = [
        "8.8.8.8"
      ];
      ipv6 = false;
    };
    sslProtocols = "TLSv1.2 TLSv1.3";
    sslCiphers = null;

    commonHttpConfig = ''
      log_format main '$remote_addr $host $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" "$http_user_agent"';
      access_log syslog:server=unix:/dev/log,nohostname main;
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

      ${LT.nginx.sslConf false}

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

      map $http_user_agent $untrusted_user_agent {
        default           0;
        ~*profound        1;
        ~*scrapyproject   1;
        ~*netcrawler      1;
        ~*nmap            1;
        ~*sqlmap          1;
        ~*slowhttptest    1;
        ~*nikto           1;
        ~*jersey          1;
        ~*brandwatch      1;
        ~*magpie-crawler  1;
        ~*mechanize       1;
        ~*python-requests 1;
        ~*redback         1;
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
      server_traffic_status_zone;

      ssl_protocols ${sslProtocols};
      ${LT.nginx.sslConf true}

      lua_package_path '/etc/nginx/conf/lua/?.lua;;';
    '';
  };

  systemd.services.nginx.serviceConfig = {
    # Workaround Lua crash
    MemoryDenyWriteExecute = pkgs.lib.mkForce false;
  };

  services.oauth2_proxy = {
    enable = true;
    clientID = "oauth-proxy";
    cookie = {
      expire = "24h";
    };
    email.domains = [ "*" ];
    httpAddress = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Oauth2Proxy}";
    keyFile = config.age.secrets.oauth2-proxy-conf.path;
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
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "3";
      DynamicUser = true;
    };
  };
}
