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
    fastcgi_param  SERVER_PORT        ${portStr.HTTPS};
    fastcgi_param  SERVER_NAME        $server_name;

    fastcgi_param  SSL_CIPHER         $ssl_cipher;
    fastcgi_param  SSL_CIPHERS        $ssl_ciphers;
    fastcgi_param  SSL_CURVES         $ssl_curves;
    fastcgi_param  SSL_PROTOCOL       $ssl_protocol;
    fastcgi_param  SSL_EARLY_DATA     $ssl_early_data;
  '';

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

  locationProxyConf = hideIP: ''
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
    proxy_set_header X-Forwarded-Host $host:${portStr.HTTPS};
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

    proxy_buffering off;
    proxy_request_buffering on;
    proxy_redirect off;
    chunked_transfer_encoding off;
  '';

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

  locationFcgiwrapConf = ''
    gzip off;
    brotli off;
    zstd off;
    try_files $fastcgi_script_name =404;
    fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
    fastcgi_index index.sh;
    ${fastcgiParams}
  '';

  locationNoTimeoutConf = ''
    client_body_buffer_size 512k;
    client_body_timeout 52w;
    client_max_body_size 0;
    grpc_read_timeout 52w;
    grpc_set_header X-Real-IP $remote_addr;
    keepalive_timeout 52w;
    proxy_connect_timeout 60;
    proxy_read_timeout 52w;
    proxy_send_timeout 52w;
    send_timeout 52w;
  '';

  compressStaticAssets = p:
    p.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.web-compressor];

      postFixup =
        (old.postFixup or "")
        + ''
          web-compressor --target $out
        '';
    });
}
