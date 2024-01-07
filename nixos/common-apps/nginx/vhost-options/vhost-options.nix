{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  name,
  config,
  ...
}: let
  listenOptions = enableDefault: portDefault: defaultDefault: {
    enable = (lib.mkEnableOption "Listener") // {default = enableDefault;};
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
    enable = (lib.mkEnableOption "Listener") // {default = enableDefault;};
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
in {
  options = {
    # Customized listen options
    listenHTTP = listenOptions false LT.port.HTTP false;
    listenHTTP_Socket = listenSocketOptions false "/run/nginx/http-${name}.sock" true;
    listenHTTPS = listenOptions true LT.port.HTTPS false;
    listenHTTPS_Socket = listenSocketOptions false "/run/nginx/https-${name}.sock" true;
    listenPlain = listenOptions false 0 true;
    listenPlainSocket = listenSocketOptions false "/run/nginx/plain-${name}.sock" true;

    # Customized vhost options
    enableCommonLocationOptions = (lib.mkEnableOption "Add common location options") // {default = true;};
    enableCommonVhostOptions = (lib.mkEnableOption "Add common vhost options") // {default = true;};

    sslCertificate = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    noIndex = {
      enable = lib.mkEnableOption "Send noindex HTTP header";
      serveRobotsTxt = (lib.mkEnableOption "Serve robots.txt that disallows crawling") // {default = true;};
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
      type = lib.types.enum ["public" "private" "localhost"];
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
      default = [];
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (import ./location-options.nix args));
      default = {};
    };
  };
}
