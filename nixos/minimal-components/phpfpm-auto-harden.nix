{
  config,
  lib,
  LT,
  serviceHardenArgs,
  ...
}:
let
  pools = config.services.phpfpm.pools;
in
{
  # Extend each pool's defaults without mapping the pool set back into itself.
  options.services.phpfpm.pools = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options.masterUser = lib.mkOption {
            type = lib.types.str;
            # A master owning its socket can run as the worker user. Cross-user
            # sockets (e.g. wordpress workers, nginx socket) need a root master.
            default =
              if
                !builtins.elem (config.settings."listen.owner" or "") [
                  ""
                  config.user
                ]
                || !builtins.elem (config.settings."listen.group" or "") [
                  ""
                  config.group
                ]
                || (config.settings.user or config.user) != config.user
                || (config.settings.group or config.group) != config.group
              then
                "root"
              else
                config.user;
            description = "PHP-FPM master identity; non-root masters must own their socket and cannot switch worker IDs.";
          };
          # Keep sockets inside each pool's private RuntimeDirectory. The upstream
          # socket option is read-only, so transform its computed path.
          options.socket = lib.mkOption {
            apply = _: "/run/phpfpm-${name}/${name}.sock";
          };
        }
      )
    );
  };

  config = {
    lantian.harden = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "phpfpm-${name}" {
        enable = true;
        passwd = true;
        etc."nsswitch.conf" = true;
      }
    ) pools;
    assertions = lib.mapAttrsToList (name: pool: {
      assertion =
        (config.systemd.services."phpfpm-${name}".serviceConfig.User or "root") == pool.masterUser
        && (pool.masterUser == "root" || pool.masterUser == pool.user);
      message = "PHP-FPM pool ${name}: set masterUser rather than overriding the service User; non-root masters must match the pool user.";
    }) pools;

    systemd.services = lib.mapAttrs' (
      name: pool:
      let
        serviceName = "phpfpm-${name}";
        rootMaster = pool.masterUser == "root";
        capabilities =
          if rootMaster then
            [
              "CAP_CHOWN"
              "CAP_FOWNER"
              "CAP_SETUID"
              "CAP_SETGID"
            ]
          else
            "";
        roots = lib.unique (
          map (vhost: toString vhost.root) (
            lib.attrValues (
              lib.filterAttrs (
                _: vhost: (vhost.phpfpmSocket or null) == pool.socket && toString vhost.root != ""
              ) (config.lantian.nginxVhosts or { })
            )
          )
        );
      in
      lib.nameValuePair serviceName {
        confinement.packages = roots;
        serviceConfig = {
          User = lib.mkDefault pool.masterUser;
          Group = lib.mkDefault (if rootMaster then "root" else pool.group);
          RestartSec = lib.mkDefault "5s";
          # PHP's JIT emits executable memory.
          MemoryDenyWriteExecute = false;
          ProtectSystem = lib.mkForce "strict";
          RestrictAddressFamilies = lib.mkForce [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          # Root masters chown host-visible sockets and drop workers to pool IDs.
          PrivateUsers = !rootMaster;
          AmbientCapabilities = capabilities;
          CapabilityBoundingSet = capabilities;
          SystemCallFilter = lib.mkForce (
            serviceHardenArgs.SystemCallFilter ++ [ "@chown" ] ++ lib.optional rootMaster "@setuid"
          );
          RuntimeDirectory = lib.mkForce [
            "phpfpm-${name}"
            "confinement/%n"
          ];
          BindReadOnlyPaths = [
            "/run/systemd/journal/dev-log:/dev/log"
          ]
          ++ map LT.escapeMountPath (lib.filter (root: !lib.hasPrefix "${builtins.storeDir}/" root) roots);
        };
      }
    ) pools;
  };
}
