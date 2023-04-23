{
  config,
  pkgs,
  lib,
  hosts,
  this,
  port,
  portStr,
  inputs,
  constants,
  ...
}: let
  fastcgiParams = ''
    set $path_info $fastcgi_path_info;

    fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param  QUERY_STRING       $query_string;
    fastcgi_param  REQUEST_METHOD     $request_method;
    fastcgi_param  CONTENT_TYPE       $content_type;
    fastcgi_param  CONTENT_LENGTH     $content_length;

    fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
    fastcgi_param  REQUEST_URI        $request_uri;
    fastcgi_param  PATH_INFO          $path_info;
    fastcgi_param  PATH_TRANSLATED    $document_root$path_info;
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
    fastcgi_param  SSL_EARLY_DATA     $ssl_early_data;
  '';

  _locationProxyConf = hideIP: ''
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP ${
      if hideIP
      then "127.0.0.1"
      else "$remote_addr"
    };
    proxy_set_header X-Forwarded-For ${
      if hideIP
      then "127.0.0.1"
      else "$remote_addr"
    };
    proxy_set_header X-Forwarded-Host $host:443;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Scheme $scheme;
    proxy_set_header X-Original-URI $request_uri;

    proxy_set_header LT-SSL-Cipher $ssl_cipher;
    proxy_set_header LT-SSL-Ciphers $ssl_ciphers;
    proxy_set_header LT-SSL-Curves $ssl_curves;
    proxy_set_header LT-SSL-Protocol $ssl_protocol;
    proxy_set_header LT-SSL-Early-Data $ssl_early_data;
    # Compatibility with common recommendations
    proxy_set_header Early-Data $ssl_early_data;

    proxy_read_timeout 1d;
    proxy_buffering off;
    proxy_request_buffering on;
    proxy_redirect off;
    chunked_transfer_encoding off;
  '';

  htpasswdFile = let
    glauthUsers = import (inputs.secrets + "/glauth-users.nix");
  in
    pkgs.writeText "htpasswd" ''
      lantian:${glauthUsers.lantian.passBcrypt}
    '';
in rec {
  getSSLPath = acmeName: "/nix/persistent/sync-servers/acme.sh/${acmeName}";
  getSSLCert = acmeName: "${getSSLPath acmeName}/fullchain.cer";
  getSSLKey = acmeName: "${getSSLPath acmeName}/${builtins.head (lib.splitString "_" acmeName)}.key";
  makeSSL = acmeName: ''
    ssl_certificate ${getSSLCert acmeName};
    ssl_certificate_key ${getSSLKey acmeName};
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate ${getSSLCert acmeName};
  '';

  commonVhostConf = ssl:
    ''
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
    ''
    + lib.optionalString ssl ''
      add_header Strict-Transport-Security 'max-age=31536000;includeSubDomains;preload';
    '';

  noIndex = enableRobotsTxtRule: let
    robotsTxt = pkgs.writeText "robots.txt" ''
      User-agent: *
      Disallow: /
    '';
  in
    ''
      add_header X-Robots-Tag 'noindex, nofollow';
    ''
    + (lib.optionalString enableRobotsTxtRule ''
      location = /robots.txt {
        alias ${robotsTxt};
      }
    '');

  serveLocalhost = ''
    access_log off;

    allow 127.0.0.1;
    allow ::1;
    deny all;
  '';

  servePrivate =
    (lib.concatMapStringsSep "\n" (ip: "allow ${ip};")
      (constants.reserved.IPv4 ++ constants.reserved.IPv6))
    + ''
      allow 127.0.0.1;
      allow ::1;
      deny all;
    '';

  addCommonLocationConf = {phpfpmSocket ? null}:
    lib.recursiveUpdate {
      "/generate_204".extraConfig = ''
        access_log off;
        return 204;
      '';

      "/autoindex.html".extraConfig = ''
        internal;
        root ${../../nixos/common-apps/nginx/files/autoindex};
      '';

      "/status".extraConfig = ''
        access_log off;
        stub_status on;
      '';

      "/ray".extraConfig = ''
        if ($content_type !~ "application/grpc") {
          return 404;
        }
        access_log off;
        client_body_buffer_size 512k;
        client_body_timeout 52w;
        client_max_body_size 0;
        grpc_pass grpc://unix:/run/v2ray/v2ray.sock;
        grpc_read_timeout 52w;
        grpc_set_header X-Real-IP $remote_addr;
        keepalive_timeout 52w;
      '';

      "/oauth2/" = {
        proxyPass = "http://${this.ltnet.IPv4}:${portStr.Oauth2Proxy}";
        extraConfig =
          ''
            proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
          ''
          + locationProxyConf;
      };

      "/oauth2/auth" = {
        proxyPass = "http://${this.ltnet.IPv4}:${portStr.Oauth2Proxy}";
        extraConfig =
          ''
            proxy_set_header Content-Length "";
            proxy_pass_request_body off;
          ''
          + locationProxyConf;
      };

      "~ ^.+?\\.php(/.*)?$".extraConfig = locationPHPConf phpfpmSocket;

      "~ ^/\\.(?!well-known).*".extraConfig = ''
        access_log off;
        return 403;
      '';
    };

  locationAutoindexConf = ''
    autoindex on;
    add_after_body /autoindex.html;
  '';

  locationBlockUserAgentConf = ''
    if ($untrusted_user_agent) {
    access_log off;
    return 403;
    }
  '';

  # https://enable-cors.org/server_nginx.html
  locationCORSConf = ''
    if ($request_method = 'OPTIONS') {
      add_header 'Access-Control-Allow-Origin' '*';
      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
      #
      # Custom headers and headers various browsers *should* be OK with but aren't
      #
      add_header 'Access-Control-Allow-Headers' 'Authorization,DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
      #
      # Tell client that this pre-flight info is valid for 20 days
      #
      add_header 'Access-Control-Max-Age' 1728000;
      add_header 'Content-Type' 'text/plain; charset=utf-8';
      add_header 'Content-Length' 0;
      return 204;
    }
    if ($request_method = 'POST') {
      add_header 'Access-Control-Allow-Origin' '*' always;
      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
      add_header 'Access-Control-Allow-Headers' 'Authorization,DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
      add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
    }
    if ($request_method = 'GET') {
      add_header 'Access-Control-Allow-Origin' '*' always;
      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
      add_header 'Access-Control-Allow-Headers' 'Authorization,DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
      add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
    }
  '';

  locationProxyConf = _locationProxyConf false;
  locationProxyConfHideIP = _locationProxyConf true;

  # Basic auth must go before proxy_pass!
  locationBasicAuthConf = ''
    auth_basic "Restricted";
    auth_basic_user_file ${htpasswdFile};
    proxy_set_header X-User $remote_user;
  '';

  # OAuth must go before proxy_pass!
  locationOauthConf = ''
    auth_request /oauth2/auth;
    error_page 401 = /oauth2/start;

    # pass information via X-User and X-Email headers to backend,
    # requires running with --set-xauthrequest flag
    auth_request_set $user   $upstream_http_x_auth_request_preferred_username;
    auth_request_set $uuid   $upstream_http_x_auth_request_user;
    auth_request_set $groups $upstream_http_x_auth_request_groups;
    auth_request_set $email  $upstream_http_x_auth_request_email;
    proxy_set_header X-User  $user;
    proxy_set_header X-Uuid  $uuid;
    proxy_set_header X-Email $email;
    proxy_set_header X-Groups $groups;

    # if you enabled --pass-access-token, this will pass the token to the backend
    auth_request_set $token  $upstream_http_x_auth_request_access_token;
    proxy_set_header X-Access-Token $token;
  '';

  locationPHPConf = phpfpmSocket:
    lib.optionalString (phpfpmSocket != null) ''
      try_files $fastcgi_script_name =404;
      fastcgi_split_path_info ^(.+\.php)(/.*)$;
      fastcgi_pass unix:${phpfpmSocket};
      fastcgi_index index.php;
      ${fastcgiParams}
      # PHP only, required if PHP was built with --enable-force-cgi-redirect
      fastcgi_param REDIRECT_STATUS 200;
      fastcgi_read_timeout 300s;
    '';

  locationFcgiwrapConf = ''
    gzip off;
    brotli off;
    zstd off;
    try_files $fastcgi_script_name =404;
    fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
    fastcgi_index index.sh;
    ${fastcgiParams}
  '';

  listenDefaultFlags = [
    "default_server"
    "fastopen=100"
    "reuseport"
    "deferred"
    "so_keepalive=600:10:6"
  ];

  listenHTTPS = listenHTTPSPort port.HTTPS;
  listenHTTPSPort = port: [
    {
      addr = "0.0.0.0";
      inherit port;
      extraParameters = ["ssl" "http2"];
    }
    {
      addr = "[::]";
      inherit port;
      extraParameters = ["ssl" "http2"];
    }
  ];

  listenHTTP = [
    {
      addr = "0.0.0.0";
      port = port.HTTP;
    }
    {
      addr = "[::]";
      port = port.HTTP;
    }
  ];

  listenProxyProtocol = ''
    set_real_ip_from 127.0.0.0/8;
    set_real_ip_from 198.18.0.0/16;
    set_real_ip_from fe80::/16;
    set_real_ip_from fdbc:f9dc:67ad::/48;
    real_ip_header proxy_protocol;
  '';
}
