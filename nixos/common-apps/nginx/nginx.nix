{
  pkgs,
  lib,
  config,
  ...
}:
let
  luaPackage = pkgs.callPackage ./lua { };

  nginxSslConf =
    isStream:
    let
      ciphersForTLS1_2 = [
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384"
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
        "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
        "TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
        "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256"
      ];
      ciphersForTLS1_3 = [
        "TLS_AES_256_GCM_SHA384"
        "TLS_CHACHA20_POLY1305_SHA256"
        "TLS_AES_128_GCM_SHA256"
      ];
      curves = [
        # Standardized post quantum curves
        # https://test.openquantumsafe.org/
        "SecP256r1MLKEM768"
        "X25519MLKEM768"

        "X25519"
        "prime256v1"
        "secp384r1"
      ];
    in
    ''
      ssl_ciphers ${builtins.concatStringsSep ":" ciphersForTLS1_2};
      ssl_ecdh_curve ${builtins.concatStringsSep ":" curves};
      ssl_conf_command Ciphersuites ${builtins.concatStringsSep ":" ciphersForTLS1_3};
      ssl_conf_command Options KTLS;
      ssl_conf_command Options PrioritizeChaCha;
    ''
    + lib.optionalString (!isStream) ''
      ssl_early_data on;
    '';
in
{
  boot.kernelModules = [ "tls" ];

  services.nginx = rec {
    enable = true;
    enableReload = true;
    package = pkgs.nur-xddxdd.lantianCustomized.nginx;
    enableQuicBPF = false;
    proxyResolveWhileRunning = true;
    proxyTimeout = "1h";
    recommendedGzipSettings = false; # use my own
    recommendedOptimisation = true;
    recommendedProxySettings = false; # use my own
    recommendedTlsSettings = true;
    resolver = {
      addresses = [ "8.8.8.8" ];
      ipv6 = false;
    };
    sslProtocols = "TLSv1.2 TLSv1.3";
    sslCiphers = null;
    sslDhparam = ./files/dhparam.pem;
    defaultMimeTypes = "${config.services.nginx.package}/conf/mime.types";

    appendConfig = ''
      worker_processes auto;
    '';
    eventsConfig = ''
      worker_connections 4096;
    '';

    commonHttpConfig = ''
      map $http_user_agent $is_not_healthcheck_user_agent {
        default                   1;
        "~*Blackbox\ Exporter"    0;
        ~*UptimeRobot             0;
        ~GcoreHealthcheckAgent    0;
      }

      log_format main '$remote_addr $host $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" "$http_user_agent"';
      access_log syslog:server=unix:/dev/log,nohostname main if=$is_not_healthcheck_user_agent;
      more_set_headers "Server: lantian/${config.networking.hostName}";

      # set to aio on; for io_uring support
      aio on;
      directio 1m;
      # sendfile on; # defined by recommendedOptimisation

      http2 on;
      http3 on;
      http3_hq on;
      quic_gso on;
      quic_retry on;

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

      ${nginxSslConf false}

      proxy_buffer_size       128k;
      proxy_buffers           4 256k;
      proxy_busy_buffers_size 256k;
      proxy_read_timeout 1d;

      vhost_traffic_status on;
      vhost_traffic_status_zone;

      stream_server_traffic_status on;
      stream_server_traffic_status_zone;

      map $server_addr $gopher_addr {
        default               gopher.lantian.pub;
        "~*^172\.22\."        gopher.lantian.dn42;
        "~*^10\.127\."        gopher.lantian.neo;
        "~*^fdbc:f9dc:67ad:"  gopher.lantian.dn42;
        "~*^fd10:127:10:"     gopher.lantian.neo;
      }

      map $http_user_agent $untrusted_user_agent {
        default           0;
        ~*brandwatch      1;
        ~*jersey          1;
        ~*magpie-crawler  1;
        ~*mechanize       1;
        ~*netcrawler      1;
        ~*nikto           1;
        ~*nmap            1;
        ~*profound        1;
        ~*python-requests 1;
        ~*redback         1;
        ~*scrapyproject   1;
        ~*slowhttptest    1;
        ~*sqlmap          1;
      }

      geoip2 /etc/geoip/GeoLite2-City.mmdb {
        auto_reload 5m;
        $geoip2_continent_code continent code;
        $geoip2_continent_name_en continent names en;
        $geoip2_continent_name_zh continent names zh-CN;
        $geoip2_country_code country iso_code;
        $geoip2_country_name_en country names en;
        $geoip2_country_name_zh country names zh-CN;
        $geoip2_city_name_en city names en;
        $geoip2_city_name_zh city names zh-CN;
        $geoip2_postal_code postal code;
      }

      geoip2 /etc/geoip/GeoLite2-ASN.mmdb {
        auto_reload 5m;
        $geoip2_asn_code autonomous_system_number;
        $geoip2_asn_name autonomous_system_organization;
      }

      port_in_redirect off;
      absolute_redirect off;
      server_name_in_redirect off;

      charset utf-8;

      lua_package_path '${luaPackage}/?.lua;;';
    '';

    streamConfig = ''
      tcp_nodelay on;
      proxy_socket_keepalive on;
      server_traffic_status_zone;

      ssl_protocols ${sslProtocols};
      ${nginxSslConf true}

      lua_package_path '${luaPackage}/?.lua;;';
    '';
  };

  services.fail2ban.jails = {
    nginx-botsearch = ''
      enabled  = true
      filter   = nginx-botsearch
      backend  = systemd
    '';
  };

  systemd.services.nginx = {
    environment = {
      # Mimalloc causes crashes on ARM64
      LD_PRELOAD = lib.optionalString pkgs.stdenv.isx86_64 "${pkgs.mimalloc}/lib/libmimalloc.so";
      inherit (config.environment.variables) OPENSSL_CONF;
    };
    serviceConfig = {
      # Workaround Lua crash
      MemoryDenyWriteExecute = lib.mkForce false;
      SystemCallFilter = lib.mkForce [ ];
      LimitMEMLOCK = "infinity";
    };
  };
}
