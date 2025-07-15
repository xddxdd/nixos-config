{ config, LT, ... }:
{
  lantian.nginxVhosts = {
    "openspeedtest.${config.networking.hostName}.xuyh0120.win" = {
      # Add layer of reverse proxy to fix abnormal upload speed
      locations."/" = {
        proxyPass = "http://127.0.0.1";
        proxyOverrideHost = "openspeedtest.localhost";
        disableLiveCompression = true;
        extraConfig = ''
          access_log off;
          client_max_body_size 35m;
          proxy_http_version 1.1;
        '';
      };

      accessibleBy = "private";
      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "openspeedtest.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      root = "${LT.sources.openspeedtest.src}";

      locations."/" = {
        disableLiveCompression = true;
        extraConfig = ''
          add_header 'Access-Control-Allow-Origin' "*" always;
          add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With' always;
          add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
          #Very Very Important! You SHOULD send no-store from server for Google Chrome.
          add_header Cache-Control 'no-store, no-cache, max-age=0, no-transform';
          add_header Last-Modified $date_gmt;
          if_modified_since off;
          expires off;
          etag off;

          if ($request_method = OPTIONS ) {
              add_header 'Access-Control-Allow-Credentials' "true";
              add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With' always;
              add_header 'Access-Control-Allow-Origin' "$http_origin" always;
              add_header 'Access-Control-Allow-Methods' "GET, POST, OPTIONS" always;
              return 200;
          }

          access_log off;
          client_max_body_size 35m;
          error_page 405 =200 $uri;
        '';
      };

      noIndex.enable = true;
      accessibleBy = "localhost";

      extraConfig = ''
        open_file_cache max=200000 inactive=20s;
        open_file_cache_valid 30s;
        open_file_cache_min_uses 2;
        open_file_cache_errors off;
      '';
    };
  };
}
