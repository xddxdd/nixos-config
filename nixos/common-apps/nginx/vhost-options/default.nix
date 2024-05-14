{ lib, config, ... }@args:
{
  options.lantian.nginxVhosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule (import ./vhost-options.nix args));
    default = { };
  };

  config = {
    services.nginx.virtualHosts = lib.mapAttrs (_: v: v._config) config.lantian.nginxVhosts;
  };
}
