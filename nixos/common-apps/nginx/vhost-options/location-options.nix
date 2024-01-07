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
}: {
  options = {
    basicAuth = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = lib.mdDoc ''
        Basic Auth protection for a vhost.

        WARNING: This is implemented to store the password in plain text in the
        Nix store.
      '';
    };

    basicAuthFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = lib.mdDoc ''
        Basic Auth password file for a vhost.
        Can be created via: {command}`htpasswd -c <filename> <username>`.

        WARNING: The generate file contains the users' passwords in a
        non-cryptographically-securely hashed way.
      '';
    };

    proxyPass = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://www.example.org/";
      description = lib.mdDoc ''
        Adds proxy_pass directive and sets recommended proxy headers if
        recommendedProxySettings is enabled.
      '';
    };

    proxyWebsockets = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = lib.mdDoc ''
        Whether to support proxying websocket connections with HTTP/1.1.
      '';
    };

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

    fastcgiParams = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.path);
      default = {};
      description = lib.mdDoc ''
        FastCGI parameters to override.  Unlike in the Nginx
        configuration file, overriding only some default parameters
        won't unset the default values for other parameters.
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
  };
}
