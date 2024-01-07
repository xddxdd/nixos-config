{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  options.lantian.nginxVhosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule (import ./vhost-options.nix args));
    default = {};
  };

  config = {
    services.nginx.virtualHosts = lib.mapAttrs (n: v:
      {
        listen = lib.mkForce (
          (lib.optionals v.listenHTTP.enable [
            {
              addr = "0.0.0.0";
              port = v.listenHTTP.port;
              extraParameters =
                (lib.optionals v.listenHTTP.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTP.default (LT.nginx.listenDefaultFlags "tcp"));
            }
            {
              addr = "[::]";
              port = v.listenHTTP.port;
              extraParameters =
                (lib.optionals v.listenHTTP.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTP.default (LT.nginx.listenDefaultFlags "tcp"));
            }
          ])
          ++ (lib.optionals v.listenHTTP_Socket.enable [
            {
              addr = "unix:${v.listenHTTP_Socket.socket}";
              extraParameters =
                (lib.optionals v.listenHTTP_Socket.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTP_Socket.default (LT.nginx.listenDefaultFlags "unix"));
            }
          ])
          ++ (lib.optionals v.listenHTTPS.enable [
            {
              addr = "0.0.0.0";
              port = v.listenHTTPS.port;
              extraParameters =
                ["ssl"]
                ++ (lib.optionals v.listenHTTPS.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTPS.default (LT.nginx.listenDefaultFlags "tcp"));
            }
            {
              addr = "0.0.0.0";
              port = v.listenHTTPS.port;
              extraParameters =
                ["quic"]
                ++ (lib.optionals v.listenHTTPS.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTPS.default (LT.nginx.listenDefaultFlags "udp"));
            }
            {
              addr = "[::]";
              port = v.listenHTTPS.port;
              extraParameters =
                ["ssl"]
                ++ (lib.optionals v.listenHTTPS.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTPS.default (LT.nginx.listenDefaultFlags "tcp"));
            }
            {
              addr = "[::]";
              port = v.listenHTTPS.port;
              extraParameters =
                ["quic"]
                ++ (lib.optionals v.listenHTTPS.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTPS.default (LT.nginx.listenDefaultFlags "udp"));
            }
          ])
          ++ (lib.optionals v.listenHTTPS_Socket.enable [
            {
              addr = "unix:${v.listenHTTPS_Socket.socket}";
              extraParameters =
                ["ssl"]
                ++ (lib.optionals v.listenHTTPS_Socket.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenHTTPS_Socket.default (LT.nginx.listenDefaultFlags "unix"));
            }
          ])
          ++ (lib.optionals v.listenPlain.enable [
            {
              addr = "0.0.0.0";
              port = v.listenPlain.port;
              extraParameters =
                ["plain"]
                ++ (lib.optionals v.listenPlain.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenPlain.default (LT.nginx.listenDefaultFlags "tcp"));
            }
            {
              addr = "[::]";
              port = v.listenPlain.port;
              extraParameters =
                ["plain"]
                ++ (lib.optionals v.listenPlain.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenPlain.default (LT.nginx.listenDefaultFlags "tcp"));
            }
          ])
          ++ (lib.optionals v.listenPlainSocket.enable [
            {
              addr = "unix:${v.listenPlainSocket.socket}";
              extraParameters =
                ["plain"]
                ++ (lib.optionals v.listenPlainSocket.proxyProtocol ["proxy_protocol"])
                ++ (lib.optionals v.listenPlainSocket.default (LT.nginx.listenDefaultFlags "unix"));
            }
          ])
        );

        locations =
          if v.enableCommonLocationOptions
          then
            LT.nginx.addCommonLocationConf {
              phpfpmSocket = v.phpfpmSocket;
              blockDotfiles = v.blockDotfiles;
            }
            v.locations
          else v.locations;

        extraConfig =
          v.extraConfig
          + (lib.optionalString (v.listenHTTPS.enable || v.listenHTTPS_Socket.enable) (
            if v.sslCertificate != null
            then LT.nginx.makeSSL v.sslCertificate
            else LT.nginx.makeSSLSnakeoil
          ))
          + (lib.optionalString v.enableCommonVhostOptions (LT.nginx.commonVhostConf (v.listenHTTPS.enable || v.listenHTTPS_Socket.enable)))
          + (lib.optionalString (
              (v.listenHTTP.enable && v.listenHTTP.proxyProtocol)
              || (v.listenHTTP_Socket.enable && v.listenHTTP_Socket.proxyProtocol)
              || (v.listenHTTPS.enable && v.listenHTTPS.proxyProtocol)
              || (v.listenHTTPS_Socket.enable && v.listenHTTPS_Socket.proxyProtocol)
              || (v.listenPlain.enable && v.listenPlain.proxyProtocol)
              || (v.listenPlainSocket.enable && v.listenPlainSocket.proxyProtocol)
            )
            LT.nginx.listenProxyProtocol)
          + (lib.optionalString v.noIndex.enable (LT.nginx.noIndex v.noIndex.serveRobotsTxt))
          + (lib.optionalString (v.accessibleBy == "private") (LT.nginx.servePrivate v.accessBlockAction))
          + (lib.optionalString (v.accessibleBy == "localhost") (LT.nginx.serveLocalhost v.accessBlockAction));

        # Passthrough upstream options
        inherit (v) serverName serverAliases;

        # I set up HTTP2/HTTP3 listening by myself
        http2 = false;
        quic = false;
        http3 = false;
        http3_hq = false;
      }
      // lib.optionalAttrs (v.root != null) {root = lib.mkForce v.root;})
    config.lantian.nginxVhosts;
  };
}
