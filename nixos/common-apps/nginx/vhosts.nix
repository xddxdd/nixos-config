{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  addConfLantianPub = args:
    lib.recursiveUpdate args {
      locations = {
        "/" = {
          index = "index.html index.htm";
        };
        "/assets/".extraConfig = ''
          expires 31536000;
        '';
        "/usr/" = {
          tryFiles = "$uri$avif_suffix$webp_suffix $uri$avif_suffix $uri$webp_suffix $uri =404";
          extraConfig = ''
            expires 31536000;
            add_header Vary "Accept";
            add_header Cache-Control "public, no-transform";
          '';
        };
        "= /favicon.ico".extraConfig = ''
          expires 31536000;
        '';
        "/feed".tryFiles = "$uri /feed.xml /atom.xml =404";

        # Plausible Analytics
        "= /api/event" = {
          proxyPass = "http://${LT.nixosConfigurations."v-ps-fal".config.lantian.netns.plausible.ipv4}:${LT.portStr.Plausible}";
        };

        # Waline
        "/comment" = {
          proxyPass = "http://${LT.hosts."v-ps-fal".ltnet.IPv4}:${LT.portStr.Waline}";
          extraConfig = ''
            proxy_set_header REMOTE-HOST $remote_addr;
          '';
        };

        # Matrix Federation
        "= /.well-known/matrix/server" = {
          allowCORS = true;
          return = "200 '${LT.constants.matrixWellKnown.server}'";
          extraConfig = ''
            default_type application/json;
          '';
        };
        "= /.well-known/matrix/client" = {
          allowCORS = true;
          return = "200 '${LT.constants.matrixWellKnown.client}'";
          extraConfig = ''
            default_type application/json;
          '';
        };
      };

      root = "/nix/persistent/sync-servers/www/lantian.pub";

      extraConfig =
        ''
          gzip off;
          gzip_static on;
          brotli off;
          brotli_static on;
          zstd off;
          zstd_static on;

          error_page 404 /404.html;
        ''
        + (args.extraConfig or "");
    };
in {
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
      serverAliases = ["${config.networking.hostName}.lantian.pub"];
      sslCertificate = "lantian.pub_ecc";
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
      sslCertificate = "lantian.pub_ecc";
    };
    "xuyh0120.win" = {
      serverAliases = ["www.xuyh0120.win"];
      locations."/".return = "307 https://lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "xuyh0120.win_ecc";
    };
    "lab.xuyh0120.win" = {
      locations."/".return = "307 https://lab.lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "xuyh0120.win_ecc";
    };
    "www.ltn.pw" = {
      locations."/".return = "307 https://ltn.pw$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "ltn.pw_ecc";
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
      serverAliases = ["gopher.lantian.dn42" "gopher.lantian.neo"];

      locations."/" = {
        index = "gophermap";
        extraConfig = ''
          sub_filter "{{server_addr}}\t{{server_port}}" "$gopher_addr\t$server_port";
          sub_filter_once off;
          sub_filter_types '*';
        '';
      };

      enableCommonLocationOptions = false;
      noIndex.enable = true;

      sslCertificate = "lantian.pub_ecc";

      extraConfig = ''
        error_page 404 /404.gopher;
      '';
    };
  };
}
