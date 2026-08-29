{
  lib,
  LT,
  config,
  self,
  pkgs,
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
            builtins.toString LT.hosts."colocrossing".index
          }.138:${LT.portStr.Plausible}";
          extraConfig = enableCompression;
        };

        # Waline
        "= /api/comment" = {
          proxyPass = "http://${LT.hosts."colocrossing".ltnet.IPv4}:${LT.portStr.Waline}";
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
        "= /.well-known/webfinger".return =
          "302 'https://mastodon.social/.well-known/webfinger?resource=acct:lantian@mastodon.social'";

        # ATproto
        "= /.well-known/atproto-did".return = "200 'did:plc:bojfoltwtzihrpbrkpkj3ijm'";

        # DN42
        "= /dn42-geofeed.csv" = {
          root = builtins.toString self.packages.${pkgs.stdenv.hostPlatform.system}.dn42-geofeed;
        };
      };

      root = "/nix/sync-servers/www/lantian.pub";

      disableLiveCompression = true;

      extraConfig = ''
        error_page 404 /404.html;
      ''
      + (args.extraConfig or "");
    };
in
{
  lantian.nginxVhosts = {
    "lantian.pub" = addConfLantianPub {
      serverAliases = [ "${config.networking.hostName}.lantian.pub" ];
      sslCertificate = "zerossl-lantian.pub";
    };
    "lantian.dn42" = addConfLantianPub {
      listenHTTP.enable = true;
      serverAliases = [ "${config.networking.hostName}.lantian.dn42" ];
      sslCertificate = "dn42-lantian.dn42";
    };
    "lantian.neo" = addConfLantianPub {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;
    };

    # Don't use globalRedirect, it adds http:// prefix
    "www.lantian.pub" = {
      locations."/".return = "307 https://lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-lantian.pub";
    };
    "xuyh0120.win" = {
      serverAliases = [ "www.xuyh0120.win" ];
      locations."/".return = "307 https://lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-xuyh0120.win";
    };
    "xn--gmqs02au1c935d.pub" = {
      serverAliases = [ "www.xn--gmqs02au1c935d.pub" ];
      locations."/".return = "307 https://lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-xn--gmqs02au1c935d.pub";
    };
    "lab.xuyh0120.win" = {
      locations."/".return = "307 https://lab.lantian.pub$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-xuyh0120.win";
    };
    "www.ltn.pw" = {
      locations."/".return = "307 https://ltn.pw$request_uri";
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-ltn.pw";
    };
  }
  // lib.optionalAttrs (LT.this.hasTag LT.tags.public-facing) {
    "gopher.lantian.pub" = {
      listenHTTP.enable = true;
      listenPlainSocket = {
        enable = true;
        socket = "/run/nginx/gopher.sock";
        proxyProtocol = true;
        default = true;
      };

      root = "/nix/sync-servers/www/lantian.pub";
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

      sslCertificate = "zerossl-lantian.pub";

      extraConfig = ''
        error_page 404 /404.gopher;
      '';
    };

    "gemini.lantian.pub" = {
      listenHTTP.enable = true;
      listenGeminiSocket = {
        enable = true;
        socket = "/run/nginx/gemini.sock";
        proxyProtocol = true;
        default = true;
      };

      root = "/nix/sync-servers/www/lantian.pub";
      serverAliases = [
        "gemini.lantian.dn42"
        "gemini.lantian.neo"
      ];

      locations."/".index = "index.gmi";

      enableCommonLocationOptions = false;
      noIndex.enable = true;

      sslCertificate = "zerossl-lantian.pub";

      extraConfig = ''
        error_page 404 /404.gopher;
      '';
    };
  };
}
