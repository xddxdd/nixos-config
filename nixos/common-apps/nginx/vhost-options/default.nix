{
  pkgs,
  lib,
  config,
  LT,
  inputs,
  ...
}:
{
  options.lantian.nginxVhosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        import ./vhost-options.nix {
          inherit
            pkgs
            lib
            LT
            config
            inputs
            ;
        }
      )
    );
    default = { };
  };

  config = {
    services.nginx.virtualHosts = lib.mapAttrs (_: v: v._config) config.lantian.nginxVhosts;
  };
}
