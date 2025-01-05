{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}@args:
let
  osConfig = config;
in
{ name, config, ... }:
let
  inherit (import ./helpers.nix args) fastcgiParams;

  listenOptions = enableDefault: portDefault: defaultDefault: {
    enable = (lib.mkEnableOption "Listener") // {
      default = enableDefault;
    };
    proxyProtocol = lib.mkEnableOption "Proxy Protocol";
    port = lib.mkOption {
      type = lib.types.int;
      default = portDefault;
    };
    default = lib.mkOption {
      type = lib.types.bool;
      default = defaultDefault;
    };
  };
  listenSocketOptions = enableDefault: socketDefault: defaultDefault: {
    enable = (lib.mkEnableOption "Listener") // {
      default = enableDefault;
    };
    proxyProtocol = lib.mkEnableOption "Proxy Protocol";
    socket = lib.mkOption {
      type = lib.types.path;
      default = socketDefault;
    };
    default = lib.mkOption {
      type = lib.types.bool;
      default = defaultDefault;
    };
  };

  addCommonLocationConf =
    {
      enable ? true,
      phpfpmSocket ? null,
      blockDotfiles ? true,
    }:
    lib.recursiveUpdate (
      lib.optionalAttrs enable (
        {
          "/generate_204".extraConfig = ''
            access_log off;
            return 204;
          '';

          "/autoindex.html".extraConfig = ''
            internal;
            root ${../files/autoindex};
          '';

          "/status".extraConfig = ''
            access_log off;
            stub_status on;
          '';

          "/ray" = {
            grpcPass = "unix:/run/v2ray/v2ray.sock";
            proxyNoTimeout = true;
            extraConfig = ''
              access_log off;
            '';
          };

          "/oauth2/" = {
            proxyPass = "http://unix:/run/oauth2-proxy/oauth2-proxy.sock";
            extraConfig = ''
              proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
            '';
          };

          "/oauth2/auth" = {
            proxyPass = "http://unix:/run/oauth2-proxy/oauth2-proxy.sock";
            extraConfig = ''
              proxy_set_header Content-Length "";
              proxy_pass_request_body off;
            '';
          };

          "= /444.internal".extraConfig = ''
            internal;
            return 444;
          '';

        }
        // lib.optionalAttrs (phpfpmSocket != null) {
          "~ ^.+?\\.php(/.*)?$".extraConfig = ''
            try_files $fastcgi_script_name =404;
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            fastcgi_pass unix:${phpfpmSocket};
            fastcgi_index index.php;
            ${fastcgiParams}
            # PHP only, required if PHP was built with --enable-force-cgi-redirect
            fastcgi_param REDIRECT_STATUS 200;
            fastcgi_read_timeout 300s;
          '';
        }
        // lib.optionalAttrs blockDotfiles {
          "~ /\\.(?!well-known).*".extraConfig = lib.optionalString blockDotfiles ''
            access_log off;
            return 403;
          '';
        }
      )
    );

  listenDefaultFlags =
    protocol:
    [ "default_server" ]
    ++ (lib.optionals (protocol == "tcp") [
      "fastopen=100"
      "reuseport"
      "deferred"
      "so_keepalive=600:10:6"
    ])
    ++ (lib.optionals (protocol == "udp") [ "reuseport" ]);

  robotsTxt = pkgs.writeText "robots.txt" ''
    User-agent: *
    Disallow: /
  '';

  generatedVhostOptions = {
    listen = lib.mkForce (
      (lib.optionals config.listenHTTP.enable [
        {
          addr = "0.0.0.0";
          inherit (config.listenHTTP) port;
          extraParameters =
            (lib.optionals config.listenHTTP.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTP.default (listenDefaultFlags "tcp"));
        }
        {
          addr = "[::]";
          inherit (config.listenHTTP) port;
          extraParameters =
            (lib.optionals config.listenHTTP.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTP.default (listenDefaultFlags "tcp"));
        }
      ])
      ++ (lib.optionals config.listenHTTP_Socket.enable [
        {
          addr = "unix:${config.listenHTTP_Socket.socket}";
          extraParameters =
            (lib.optionals config.listenHTTP_Socket.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTP_Socket.default (listenDefaultFlags "unix"));
        }
      ])
      ++ (lib.optionals config.listenHTTPS.enable [
        {
          addr = "0.0.0.0";
          inherit (config.listenHTTPS) port;
          extraParameters =
            [ "ssl" ]
            ++ (lib.optionals config.listenHTTPS.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTPS.default (listenDefaultFlags "tcp"));
        }
        {
          addr = "0.0.0.0";
          inherit (config.listenHTTPS) port;
          extraParameters =
            [ "quic" ]
            ++ (lib.optionals config.listenHTTPS.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTPS.default (listenDefaultFlags "udp"));
        }
        {
          addr = "[::]";
          inherit (config.listenHTTPS) port;
          extraParameters =
            [ "ssl" ]
            ++ (lib.optionals config.listenHTTPS.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTPS.default (listenDefaultFlags "tcp"));
        }
        {
          addr = "[::]";
          inherit (config.listenHTTPS) port;
          extraParameters =
            [ "quic" ]
            ++ (lib.optionals config.listenHTTPS.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTPS.default (listenDefaultFlags "udp"));
        }
      ])
      ++ (lib.optionals config.listenHTTPS_Socket.enable [
        {
          addr = "unix:${config.listenHTTPS_Socket.socket}";
          extraParameters =
            [ "ssl" ]
            ++ (lib.optionals config.listenHTTPS_Socket.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenHTTPS_Socket.default (listenDefaultFlags "unix"));
        }
      ])
      ++ (lib.optionals config.listenPlain.enable [
        {
          addr = "0.0.0.0";
          inherit (config.listenPlain) port;
          extraParameters =
            [ "plain" ]
            ++ (lib.optionals config.listenPlain.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenPlain.default (listenDefaultFlags "tcp"));
        }
        {
          addr = "[::]";
          inherit (config.listenPlain) port;
          extraParameters =
            [ "plain" ]
            ++ (lib.optionals config.listenPlain.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenPlain.default (listenDefaultFlags "tcp"));
        }
      ])
      ++ (lib.optionals config.listenPlainSocket.enable [
        {
          addr = "unix:${config.listenPlainSocket.socket}";
          extraParameters =
            [ "plain" ]
            ++ (lib.optionals config.listenPlainSocket.proxyProtocol [ "proxy_protocol" ])
            ++ (lib.optionals config.listenPlainSocket.default (listenDefaultFlags "unix"));
        }
      ])
    );

    locations = lib.mapAttrs (_n: v: v._config) config._locationsWithCommon;

    extraConfig =
      config.extraConfig
      + (lib.optionalString (config.listenHTTPS.enable || config.listenHTTPS_Socket.enable) (
        if config.sslCertificate != null then
          ''
            ssl_certificate ${LT.nginx.getSSLCert config.sslCertificate};
            ssl_certificate_key ${LT.nginx.getSSLKey config.sslCertificate};
            ssl_stapling on;
            ssl_stapling_verify on;
            ssl_trusted_certificate ${LT.nginx.getSSLCert config.sslCertificate};
          ''
        else
          ''
            ssl_certificate ${inputs.secrets + "/ssl-cert-snakeoil.pem"};
            ssl_certificate_key ${inputs.secrets + "/ssl-cert-snakeoil.key"};
            ssl_stapling on;
            ssl_stapling_verify on;
            ssl_trusted_certificate ${inputs.secrets + "/ssl-cert-snakeoil.pem"};
          ''
      ))
      + (lib.optionalString config.enableCommonVhostOptions ''
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
      '')
      + (lib.optionalString
        (config.enableCommonVhostOptions && (config.listenHTTPS.enable || config.listenHTTPS_Socket.enable))
        ''
          add_header Strict-Transport-Security 'max-age=31536000;includeSubDomains;preload';
          add_header Alt-Svc 'h3=":${builtins.toString config.listenHTTPS.port}"; ma=86400';
        ''
      )
      + (lib.optionalString
        (
          (config.listenHTTP.enable && config.listenHTTP.proxyProtocol)
          || (config.listenHTTP_Socket.enable && config.listenHTTP_Socket.proxyProtocol)
          || (config.listenHTTPS.enable && config.listenHTTPS.proxyProtocol)
          || (config.listenHTTPS_Socket.enable && config.listenHTTPS_Socket.proxyProtocol)
          || (config.listenPlain.enable && config.listenPlain.proxyProtocol)
          || (config.listenPlainSocket.enable && config.listenPlainSocket.proxyProtocol)
        )
        ''
          set_real_ip_from 127.0.0.0/8;
          set_real_ip_from 198.18.0.0/15;
          set_real_ip_from fe80::/16;
          set_real_ip_from fdbc:f9dc:67ad::/48;
          real_ip_header proxy_protocol;
        ''
      )
      + (lib.optionalString config.noIndex.enable ''
        add_header X-Robots-Tag 'noindex, nofollow';
      '')
      + (lib.optionalString (config.noIndex.enable && config.noIndex.serveRobotsTxt) ''
        location = /robots.txt {
          alias ${robotsTxt};
        }
      '')
      + (lib.optionalString (config.accessibleBy == "private") ''
        ${lib.concatMapStringsSep "\n" (ip: "allow ${ip};") (
          LT.constants.reserved.IPv4 ++ LT.constants.reserved.IPv6
        )}
        allow 127.0.0.1;
        allow ::1;
        deny all;

        error_page 403 ${config.accessBlockAction};
      '')
      + (lib.optionalString (config.accessibleBy == "localhost") ''
        access_log off;

        allow 127.0.0.1;
        allow ::1;
        deny all;

        error_page 403 ${config.accessBlockAction};
      '')
      + (lib.optionalString config.disableLiveCompression ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;
        zstd off;
        zstd_static on;
      '');

    # Passthrough upstream options
    inherit (config) serverName serverAliases;

    # I set up HTTP2/HTTP3 listening by myself
    http2 = false;
    quic = false;
    http3 = false;
    http3_hq = false;
  } // lib.optionalAttrs (config.root != null) { root = lib.mkForce config.root; };
in
{
  options = {
    # Customized listen options
    listenHTTP = listenOptions false LT.port.HTTP false;
    listenHTTP_Socket = listenSocketOptions false "/run/nginx/http-${name}.sock" true;
    listenHTTPS = listenOptions true LT.port.HTTPS false;
    listenHTTPS_Socket = listenSocketOptions false "/run/nginx/https-${name}.sock" true;
    listenPlain = listenOptions false 0 true;
    listenPlainSocket = listenSocketOptions false "/run/nginx/plain-${name}.sock" true;

    # Customized vhost options
    enableCommonLocationOptions = (lib.mkEnableOption "Add common location options") // {
      default = true;
    };
    enableCommonVhostOptions = (lib.mkEnableOption "Add common vhost options") // {
      default = true;
    };
    disableLiveCompression = lib.mkEnableOption "Disable on-the-fly compression and only use precompressed assets";

    sslCertificate = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    noIndex = {
      enable = lib.mkEnableOption "Send noindex HTTP header";
      serveRobotsTxt = (lib.mkEnableOption "Serve robots.txt that disallows crawling") // {
        default = true;
      };
    };

    phpfpmSocket = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    blockDotfiles = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    accessibleBy = lib.mkOption {
      type = lib.types.enum [
        "public"
        "private"
        "localhost"
      ];
      default = "public";
    };

    accessBlockAction = lib.mkOption {
      type = lib.types.str;
      default = "/444.internal";
    };

    # Upstream vhost options
    root = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    serverName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = name;
    };

    serverAliases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          import ./location-options.nix {
            inherit
              pkgs
              lib
              LT
              inputs
              ;
            config = osConfig;
          }
        )
      );
      default = { };
    };

    _locationsWithCommon = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          import ./location-options.nix {
            inherit
              pkgs
              lib
              LT
              inputs
              ;
            config = osConfig;
          }
        )
      );
      default = addCommonLocationConf {
        enable = config.enableCommonLocationOptions;
        inherit (config) phpfpmSocket;
        inherit (config) blockDotfiles;
      } (lib.mapAttrs (_n: v: builtins.removeAttrs v [ "_config" ]) config.locations);
    };

    _config = lib.mkOption {
      readOnly = true;
      default = generatedVhostOptions;
    };
  };
}
