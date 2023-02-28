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
          proxyPass = "http://${LT.hosts."oneprovider".ltnet.IPv4Prefix}.${LT.constants.containerIP.plausible}:${LT.portStr.Plausible}";
          extraConfig = LT.nginx.locationProxyConf;
        };

        # Waline
        "/comment".extraConfig =
          ''
            proxy_pass http://${LT.hosts."oneprovider".ltnet.IPv4}:${LT.portStr.Waline};
            proxy_set_header REMOTE-HOST $remote_addr;
          ''
          + LT.nginx.locationProxyConf;

        # Matrix Federation
        "= /.well-known/matrix/server".extraConfig = let
          # use 443 instead of the default 8448 port to unite
          # the client-server and server-server port for simplicity
          server = {
            "m.server" = "matrix.lantian.pub:${LT.portStr.Matrix.Public}";
          };
        in ''
          default_type application/json;
          return 200 '${builtins.toJSON server}';
        '';
        "= /.well-known/matrix/client".extraConfig = let
          client = {
            "m.homeserver" = {
              "base_url" = "https://matrix.lantian.pub";
            };
            "m.identity_server" = {
              "base_url" = "https://vector.im";
            };
          };
          # ACAO required to allow element-web on any URL to request this json file
        in ''
          default_type application/json;
          add_header Access-Control-Allow-Origin *;
          return 200 '${builtins.toJSON client}';
        '';
      };

      root = "/nix/persistent/sync-servers/www/lantian.pub";

      extraConfig =
        ''
          gzip off;
          gzip_static on;
          brotli off;
          brotli_static on;

          error_page 404 /404.html;
        ''
        + args.extraConfig;
    };
in {
  services.nginx.virtualHosts = {
    "localhost" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          extraParameters = ["ssl" "http2"] ++ LT.nginx.listenDefaultFlags;
        }
        {
          addr = "[::]";
          port = 443;
          extraParameters = ["ssl" "http2"] ++ LT.nginx.listenDefaultFlags;
        }
        {
          addr = "0.0.0.0";
          port = 80;
          extraParameters = LT.nginx.listenDefaultFlags;
        }
        {
          addr = "[::]";
          port = 80;
          extraParameters = LT.nginx.listenDefaultFlags;
        }
      ];

      locations = {
        "/".return = "301 https://$host$request_uri";
        "= /.well-known/openid-configuration".extraConfig = ''
          root ${files/openid-configuration};
          try_files /openid-configuration =404;
        '';
        "= /openid-configuration".extraConfig = ''
          root ${files/openid-configuration};
          try_files /openid-configuration =404;
        '';
        "/generate_204".return = "204";
      };

      extraConfig = ''
        access_log off;
        ssl_reject_handshake on;
        ssl_stapling off;
      '';
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

    "www.lantian.pub" = {
      listen = LT.nginx.listenHTTPS ++ LT.nginx.listenHTTP;
      globalRedirect = "lantian.pub";
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS ++ LT.nginx.listenHTTP;
      serverAliases = ["www.xuyh0120.win"];
      globalRedirect = "lantian.pub";
      extraConfig =
        LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "lab.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS ++ LT.nginx.listenHTTP;
      globalRedirect = "lab.lantian.pub";
      extraConfig =
        LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "ltn.pw" = {
      listen = LT.nginx.listenHTTPS ++ LT.nginx.listenHTTP;
      serverAliases = ["www.ltn.pw"];
      globalRedirect = "lantian.pub";
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
