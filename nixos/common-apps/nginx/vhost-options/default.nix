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

  options.lantian.localVhosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule [
        (import ./vhost-options.nix {
          inherit
            pkgs
            lib
            LT
            config
            inputs
            ;
        })
        {
          config = {
            accessibleBy = lib.mkDefault "private";
            sslCertificate = lib.mkDefault "zerossl-${config.networking.hostName}.xuyh0120.win";
            noIndex.enable = lib.mkDefault true;
          };
        }
      ]
    );
    default = { };
  };

  config = {
    services.nginx.virtualHosts = lib.mapAttrs (_: v: v._config) config.lantian.nginxVhosts;

    lantian.nginxVhosts = lib.concatMapAttrs (
      name: v:
      let
        shared =
          (builtins.removeAttrs v [
            "_config"
            "_locationsWithCommon"
            "serverName"
            "accessibleBy"
          ])
          // {
            locations = lib.mapAttrs (_: l: builtins.removeAttrs l [ "_config" ]) v.locations;
          };
      in
      {
        "${name}.${config.networking.hostName}.xuyh0120.win" = shared // {
          listenHTTP = shared.listenHTTP // {
            enable = false;
          };
          listenHTTPS = shared.listenHTTPS // {
            enable = true;
          };
          inherit (v) accessibleBy;
        };
        "${name}.localhost" = shared // {
          listenHTTP = shared.listenHTTP // {
            enable = true;
          };
          listenHTTPS = shared.listenHTTPS // {
            enable = false;
          };
          accessibleBy = "localhost";
        };
      }
    ) config.lantian.localVhosts;
  };
}
