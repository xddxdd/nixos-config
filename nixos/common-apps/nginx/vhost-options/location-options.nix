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
  generatedLocationOptions = {
    inherit (config) priority;
    extraConfig =
      (lib.optionalString config.enableOAuth LT.nginx.locationOauthConf)
      + (lib.optionalString config.enableBasicAuth LT.nginx.locationBasicAuthConf)
      + (lib.optionalString (config.proxyPass != null) ''
        set $nix_proxy_target "${config.proxyPass}";
        proxy_pass $nix_proxy_target;
        ${LT.nginx.locationProxyConf config.proxyHideIP}
      '')
      + (lib.optionalString config.proxyWebsockets ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '')
      + (lib.optionalString config.proxyNoTimeout LT.nginx.locationNoTimeoutConf)
      + (lib.optionalString config.allowCORS LT.nginx.locationCORSConf)
      + (lib.optionalString config.enableAutoIndex LT.nginx.locationAutoindexConf)
      + (lib.optionalString (config.index != null) ''
        index ${config.index};
      '')
      + (lib.optionalString config.blockBadUserAgents LT.nginx.locationBlockUserAgentConf)
      + (lib.optionalString config.enableFcgiwrap LT.nginx.locationFcgiwrapConf)
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
in {
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
      type = with lib.types; nullOr (oneOf [str int]);
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
