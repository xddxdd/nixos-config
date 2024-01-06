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
      locations = LT.nginx.addCommonLocationConf {} {
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
          extraConfig = LT.nginx.locationProxyConf;
        };

        # Waline
        "/comment".extraConfig =
          ''
            proxy_pass http://${LT.hosts."v-ps-fal".ltnet.IPv4}:${LT.portStr.Waline};
            proxy_set_header REMOTE-HOST $remote_addr;
          ''
          + LT.nginx.locationProxyConf;

        # Matrix Federation
        "= /.well-known/matrix/server".extraConfig =
          LT.nginx.locationCORSConf
          + ''
            default_type application/json;
            return 200 '${LT.constants.matrixWellKnown.server}';
          '';
        "= /.well-known/matrix/client".extraConfig =
          LT.nginx.locationCORSConf
          + ''
            default_type application/json;
            return 200 '${LT.constants.matrixWellKnown.client}';
          '';
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
        + args.extraConfig;
    };
in {
  services.nginx.virtualHosts = {
    "_default_http" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = LT.port.HTTP;
          extraParameters = LT.nginx.listenDefaultFlags;
        }
        {
          addr = "[::]";
          port = LT.port.HTTP;
          extraParameters = LT.nginx.listenDefaultFlags;
        }
      ];

      locations = {
        "/".return = "301 https://$host$request_uri";
        "/generate_204".return = "204";
      };

      extraConfig = ''
        access_log off;
      '';
    };

    "_default_https" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = LT.port.HTTPS;
          extraParameters = ["ssl"] ++ LT.nginx.listenDefaultFlags;
        }
        {
          addr = "0.0.0.0";
          port = LT.port.HTTPS;
          extraParameters = ["quic"] ++ LT.nginx.listenDefaultFlagsQuic;
        }
        {
          addr = "[::]";
          port = LT.port.HTTPS;
          extraParameters = ["ssl"] ++ LT.nginx.listenDefaultFlags;
        }
        {
          addr = "[::]";
          port = LT.port.HTTPS;
          extraParameters = ["quic"] ++ LT.nginx.listenDefaultFlagsQuic;
        }
      ];

      locations = {
        "/".return = "444";
        "/generate_204".return = "204";
      };

      extraConfig =
        ''
          access_log off;
        ''
        + LT.nginx.makeSSLSnakeoil;
    };

    "localhost" = {
      listen = LT.nginx.listenHTTP;
      root = "/var/www/localhost";
      extraConfig = LT.nginx.commonVhostConf false;
    };

    "lantian.pub" = addConfLantianPub {
      listen = LT.nginx.listenHTTPS;
      serverAliases = ["${config.networking.hostName}.lantian.pub"];
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "lantian.dn42" = addConfLantianPub {
      listen = LT.nginx.listenHTTP;
      extraConfig = LT.nginx.commonVhostConf false;
    };
    "lantian.neo" = addConfLantianPub {
      listen = LT.nginx.listenHTTP;
      extraConfig = LT.nginx.commonVhostConf false;
    };

    # Don't use globalRedirect, it adds http:// prefix
    "www.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations."/".return = "302 https://lantian.pub$request_uri";
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      serverAliases = ["www.xuyh0120.win"];
      locations."/".return = "302 https://lantian.pub$request_uri";
      extraConfig =
        LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "lab.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations."/".return = "302 https://lab.lantian.pub$request_uri";
      extraConfig =
        LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "www.ltn.pw" = {
      listen = LT.nginx.listenHTTPS;
      locations."/".return = "302 https://ltn.pw$request_uri";
      extraConfig =
        LT.nginx.makeSSL "ltn.pw_ecc"
        + LT.nginx.commonVhostConf true;
    };

    "gopher.lantian.pub" = {
      listen = LT.nginx.listenHTTPS ++ LT.nginx.listenHTTP;
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

      extraConfig =
        ''
          listen unix:/run/nginx/gopher.sock plain proxy_protocol default_server;
          error_page 404 /404.gopher;
        ''
        + LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.listenProxyProtocol
        + LT.nginx.noIndex true;
    };
  };
}
