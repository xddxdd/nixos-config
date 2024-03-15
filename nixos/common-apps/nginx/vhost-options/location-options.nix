{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  osConfig = config;

  inherit (import ./helpers.nix args) fastcgiParams;

  htpasswdFile =
    let
      glauthUsers = import (inputs.secrets + "/glauth-users.nix");
    in
    pkgs.writeText "htpasswd" ''
      lantian:${glauthUsers.lantian.passBcrypt}
    '';
in
{ name, config, ... }:
let
  generatedLocationOptions = {
    inherit (config) priority;
    extraConfig =
      (lib.optionalString config.enableOAuth ''
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
      '')
      + (lib.optionalString config.enableBasicAuth ''
        auth_basic "Restricted";
        auth_basic_user_file ${htpasswdFile};
        proxy_set_header X-User $remote_user;
      '')
      + (lib.optionalString (config.proxyPass != null) ''
        proxy_pass ${config.proxyPass};

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP ${if config.proxyHideIP then "127.0.0.1" else "$remote_addr"};
        proxy_set_header X-Forwarded-For ${if config.proxyHideIP then "127.0.0.1" else "$remote_addr"};
        proxy_set_header X-Forwarded-Host $host:${LT.portStr.HTTPS};
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
      '')
      + (lib.optionalString config.proxyWebsockets ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '')
      + (lib.optionalString config.proxyNoTimeout ''
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
      '')
      + (lib.optionalString config.allowCORS
        # https://enable-cors.org/server_nginx.html
        ''
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
        ''
      )
      + (lib.optionalString config.enableAutoIndex ''
        autoindex on;
        add_after_body /autoindex.html;
      '')
      + (lib.optionalString (config.index != null) ''
        index ${config.index};
      '')
      + (lib.optionalString config.blockBadUserAgents ''
        if ($untrusted_user_agent) {
          access_log off;
          return 403;
        }
      '')
      + (lib.optionalString config.enableFcgiwrap ''
        gzip off;
        brotli off;
        zstd off;
        try_files $fastcgi_script_name =404;
        fastcgi_pass unix:${osConfig.services.fcgiwrap.socketAddress};
        fastcgi_index index.sh;
        ${fastcgiParams}
      '')
      + (lib.optionalString (config.tryFiles != null) ''
        try_files ${config.tryFiles};
      '')
      + (lib.optionalString (config.root != null) ''
        root ${config.root};
      '')
      + (lib.optionalString (config.alias != null) ''
        alias ${config.alias};
      '')
      + (lib.optionalString (config.return != null) ''
        return ${toString config.return};
      '')
      + config.extraConfig;
  };
in
{
  options = {
    proxyPass = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://www.example.org/";
      description = lib.mdDoc ''
        Adds proxy_pass directive and sets recommended proxy headers if
        recommendedProxySettings is enabled.
      '';
    };

    proxyHideIP = lib.mkEnableOption "Hide client IP from backend";

    proxyWebsockets = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = lib.mdDoc ''
        Whether to support proxying websocket connections with HTTP/1.1.
      '';
    };

    proxyNoTimeout = lib.mkEnableOption "Disable timeout for proxy requests";

    allowCORS = lib.mkEnableOption "Allow all CORS requests";
    blockBadUserAgents = lib.mkEnableOption "Block bad user agents";
    enableAutoIndex = lib.mkEnableOption "Auto show index for content";
    enableBasicAuth = lib.mkEnableOption "Require basic auth for access";
    enableFcgiwrap = lib.mkEnableOption "Fcgiwrap";
    enableOAuth = lib.mkEnableOption "Require OAuth for access";

    index = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "index.php index.html";
      description = lib.mdDoc ''
        Adds index directive.
      '';
    };

    tryFiles = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "$uri =404";
      description = lib.mdDoc ''
        Adds try_files directive.
      '';
    };

    root = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/your/root/directory";
      description = lib.mdDoc ''
        Root directory for requests.
      '';
    };

    alias = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/your/alias/directory";
      description = lib.mdDoc ''
        Alias directory for requests.
      '';
    };

    return = lib.mkOption {
      type =
        with lib.types;
        nullOr (oneOf [
          str
          int
        ]);
      default = null;
      example = "301 http://example.com$request_uri";
      description = lib.mdDoc ''
        Adds a return directive, for e.g. redirections.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = lib.mdDoc ''
        These lines go to the end of the location verbatim.
      '';
    };

    priority = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = lib.mdDoc ''
        Order of this location block in relation to the others in the vhost.
        The semantics are the same as with `lib.mkOrder`. Smaller values have
        a greater priority.
      '';
    };

    _config = lib.mkOption {
      readOnly = true;
      default = generatedLocationOptions;
    };
  };
}
