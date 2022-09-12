{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  luaPackage = pkgs.callPackage ./lua { };

  opensslConfig = pkgs.writeText "openssl.conf" ''
    openssl_conf = openssl_init

    [openssl_init]
    providers = provider_sect

    [provider_sect]
    oqsprovider = oqsprovider_sect
    default = default_sect
    # fips = fips_sect

    [default_sect]
    activate = 1

    #[fips_sect]
    #activate = 1

    [oqsprovider_sect]
    activate = 1
    module = ${pkgs.openssl-oqs-provider}/lib/oqsprovider.so
  '';

  nginxSslConf = isStream:
    let
      ciphersForTLS1_2 = [
        "ECDHE-ECDSA-AES256-GCM-SHA384"
        "ECDHE-RSA-AES256-GCM-SHA384"
        "ECDHE-ECDSA-CHACHA20-POLY1305"
        "ECDHE-RSA-CHACHA20-POLY1305"
        "ECDHE-ECDSA-AES128-GCM-SHA256"
        "ECDHE-RSA-AES128-GCM-SHA256"
        "DHE-RSA-AES256-GCM-SHA384"
        "DHE-RSA-CHACHA20-POLY1305"
        "DHE-RSA-AES128-GCM-SHA256"
      ];
      ciphersForTLS1_3 = [
        "TLS_AES_256_GCM_SHA384"
        "TLS_CHACHA20_POLY1305_SHA256"
        "TLS_AES_128_GCM_SHA256"
      ];
      curves = [
        "p256_frodo640aes"
        "p256_bikel1"
        "p256_kyber90s512"
        "p256_ntru_hps2048509"
        "p256_lightsaber"
        "prime256v1"
        "secp384r1"
        "secp521r1"
      ];
    in
    ''
      ssl_ciphers ${builtins.concatStringsSep ":" ciphersForTLS1_2};
      ssl_session_timeout 1d;
      ssl_session_cache shared:${if isStream then "SSL_STREAM" else "SSL_HTTP"}:10m;
      ssl_session_tickets on;
      ssl_prefer_server_ciphers on;
      ssl_ecdh_curve ${builtins.concatStringsSep ":" curves};
      ssl_conf_command Ciphersuites ${builtins.concatStringsSep ":" ciphersForTLS1_3};
      ssl_conf_command Options KTLS;
      ssl_conf_command Options PrioritizeChaCha;
    '' + lib.optionalString (!isStream) ''
      ssl_early_data on;
      ssl_dyn_rec_enable on;
    '';
in
{
  services.nginx = rec {
    enable = true;
    enableReload = true;
    package = pkgs.lantianCustomized.openresty.override {
      openssl-oqs = pkgs.openssl-oqs.override {
        inherit (config.boot.kernelPackages) cryptodev;
      };
    };
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

      aio threads;
      directio 1m;
      # sendfile on; # defined by recommendedOptimisation

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

  systemd.services.nginx = {
    environment = {
      LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
      OPENSSL_CONF = builtins.toString opensslConfig;
    };
    serviceConfig = {
      # Workaround Lua crash
      MemoryDenyWriteExecute = lib.mkForce false;
      SystemCallFilter = lib.mkForce [ ];
    };
  };
}
