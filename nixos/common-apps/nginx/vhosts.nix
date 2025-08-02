{
  lib,
  LT,
  config,
  ...
}:
let
  addConfLantianPub =
    args:
    let
      enableCompression = ''
        gzip on;
        brotli on;
        zstd on;
      '';
    in
    lib.recursiveUpdate args {
      locations = {
        "/" = {
          index = "index.html index.htm";
        };
        "/assets/".extraConfig = ''
          expires 31536000;
        '';
        "/usr/".extraConfig = ''
          expires 31536000;
          add_header Vary "Accept";
          add_header Cache-Control "public, no-transform";
        '';
        "= /favicon.ico".extraConfig = ''
          expires 31536000;
        '';
        "/feed".tryFiles = "$uri /feed.xml /atom.xml =404";

        # Plausible Analytics
        "= /api/event" = {
          proxyPass = "http://198.18.${
            builtins.toString LT.hosts."hetzner-de".index
          }.138:${LT.portStr.Plausible}";
          extraConfig = enableCompression;
        };

        # Waline
        "= /api/comment" = {
          proxyPass = "http://${LT.hosts."hetzner-de".ltnet.IPv4}:${LT.portStr.Waline}";
          extraConfig = ''
            proxy_set_header REMOTE-HOST $remote_addr;
            ${enableCompression}
          '';
        };

        # Matrix Federation
        "= /.well-known/matrix/server" = {
          allowCORS = true;
          return = "200 '${LT.constants.matrixWellKnown.server}'";
          extraConfig = ''
            default_type application/json;
            ${enableCompression}
          '';
        };
        "= /.well-known/matrix/client" = {
          allowCORS = true;
          return = "200 '${LT.constants.matrixWellKnown.client}'";
          extraConfig = ''
            default_type application/json;
            ${enableCompression}
          '';
        };
        "= /.well-known/webfinger".extraConfig = ''
          # Manually setup proxy to avoid passing proxy headers
          # Add a variable to force use URL set by me
          set $account "lantian@mastodon.social";
          proxy_pass "https://mastodon.social/.well-known/webfinger?resource=acct:$account";
          proxy_ssl_name mastodon.social;
          proxy_ssl_server_name on;
          ${enableCompression}
        '';
      };

      root = "/nix/persistent/sync-servers/www/lantian.pub";

      disableLiveCompression = true;

      extraConfig = ''
        error_page 404 /404.html;
      ''
      + (args.extraConfig or "");
    };
in
{
  lantian.nginxVhosts = {
    "_default_http" = {
      listenHTTP.enable = true;
      listenHTTP.default = true;
      listenHTTPS.enable = false;

      locations = {
        "/".return = "301 https://$host$request_uri";
        "/generate_204".return = "204";
      };

      enableCommonLocationOptions = false;
      enableCommonVhostOptions = false;

      extraConfig = ''
        access_log off;
      '';
    };

    "_default_https" = {
      listenHTTPS.default = true;

      locations = {
        "/".return = "444";
        "/generate_204".return = "204";
      };

      enableCommonLocationOptions = false;
      enableCommonVhostOptions = false;

      extraConfig = ''
        access_log off;
      '';
    };

    "localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;
      root = "/var/www/localhost";
      enableCommonLocationOptions = false;
      accessibleBy = "localhost";
    };

    "lantian.pub" = addConfLantianPub {
      serverAliases = [ "${config.networking.hostName}.lantian.pub" ];
      sslCertificate = "lets-encrypt-lantian.pub";
    };
    "lantian.dn42" = addConfLantianPub {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;
    };
    "lantian.neo" = addConfLantianPub {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;
    };

    # Don't use globalRedirect, it adds http:// prefix
    "www.lantian.pub" = {
      locations."/".return = "307 https://lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "lets-encrypt-lantian.pub";
    };
    "xuyh0120.win" = {
      serverAliases = [ "www.xuyh0120.win" ];
      locations."/".return = "307 https://lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "lets-encrypt-xuyh0120.win";
    };
    "lab.xuyh0120.win" = {
      locations."/".return = "307 https://lab.lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "lets-encrypt-xuyh0120.win";
    };
    "www.ltn.pw" = {
      locations."/".return = "307 https://ltn.pw$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "lets-encrypt-ltn.pw";
    };

    "gopher.lantian.pub" = {
      listenHTTP.enable = true;
      listenPlainSocket = {
        enable = true;
        socket = "/run/nginx/gopher.sock";
        proxyProtocol = true;
        default = true;
      };

      root = "/nix/persistent/sync-servers/www/lantian.pub";
      serverAliases = [
        "gopher.lantian.dn42"
        "gopher.lantian.neo"
      ];

      locations."/" = {
        index = "gophermap";
        extraConfig = ''
          sub_filter "{{server_addr}}\t{{server_port}}" "$gopher_addr\t70";
          sub_filter_once off;
          sub_filter_types '*';
        '';
      };

      enableCommonLocationOptions = false;
      noIndex.enable = true;

      sslCertificate = "lets-encrypt-lantian.pub";

      extraConfig = ''
        error_page 404 /404.gopher;
      '';
    };
  };
}
