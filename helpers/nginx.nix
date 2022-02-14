{ config
, lib
, hosts
, this
, port
, portStr
, ...
}:

let
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
  '';
in
rec {
  makeSSL = acmeName:
    let
      acmeHost = lib.elemAt (lib.splitString "_" acmeName) 0;
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
  '' + lib.optionalString ssl ''
    add_header Strict-Transport-Security 'max-age=31536000;includeSubDomains;preload';
  '';

  noIndex = ''
    add_header X-Robots-Tag 'noindex, nofollow';
  '';

  addCommonLocationConf = lib.recursiveUpdate {
    "/generate_204".extraConfig = ''
      access_log off;
      return 204;
    '';

    "/autoindex.html".extraConfig = ''
      internal;
      root ${../nixos/files/autoindex};
    '';

    "/status".extraConfig = ''
      access_log off;
      stub_status on;
    '';

    "/ray" = {
      proxyPass = "http://127.0.0.1:${portStr.V2Ray}";
      proxyWebsockets = true;
      extraConfig = ''
        access_log off;
        keepalive_timeout 1d;
      '' + locationProxyConf;
    };

    "/oauth2/" = {
      proxyPass = "http://${this.ltnet.IPv4}:${portStr.Oauth2Proxy}";
      extraConfig = ''
        proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
      '' + locationProxyConf;
    };

    "/oauth2/auth" = {
      proxyPass = "http://${this.ltnet.IPv4}:${portStr.Oauth2Proxy}";
      extraConfig = ''
        proxy_set_header Content-Length "";
        proxy_pass_request_body off;
      '' + locationProxyConf;
    };

    "~ ^.+?\\.php(/.*)?$".extraConfig = lib.optionalString (config.lantian.enable-php) locationPHPConf;

    "~ /\\.(?!well-known).*".extraConfig = ''
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

  locationPHPConf = ''
    try_files $fastcgi_script_name =404;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    fastcgi_pass unix:${config.services.phpfpm.pools.www.socket};
    fastcgi_index index.php;
    ${fastcgiParams}
    # PHP only, required if PHP was built with --enable-force-cgi-redirect
    fastcgi_param REDIRECT_STATUS 200;
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

  listenHTTPS = [
    { addr = "0.0.0.0"; port = port.HTTPS; extraParameters = [ "ssl" "http2" ]; }
    { addr = "[::]"; port = port.HTTPS; extraParameters = [ "ssl" "http2" ]; }
  ];

  listenHTTP = [
    { addr = "0.0.0.0"; port = port.HTTP; }
    { addr = "[::]"; port = port.HTTP; }
  ];

  listenPlain = port: [
    { addr = "0.0.0.0"; port = port; extraParameters = [ "plain" ] ++ listenDefaultFlags; }
    { addr = "[::]"; port = port; extraParameters = [ "plain" ] ++ listenDefaultFlags; }
  ];

  listenPlainProxyProtocol = port: [
    { addr = "${this.ltnet.IPv4}"; port = port; extraParameters = [ "plain" "proxy_protocol" ] ++ listenDefaultFlags; }
    { addr = "[${this.ltnet.IPv6}]"; port = port; extraParameters = [ "plain" "proxy_protocol" ] ++ listenDefaultFlags; }
  ];

  listenProxyProtocol = ''
    set_real_ip_from 127.0.0.0/8;
    set_real_ip_from 172.18.0.0/16;
    set_real_ip_from fe80::/16;
    set_real_ip_from fdbc:f9dc:67ad::/48;
    real_ip_header proxy_protocol;
  '';
}
