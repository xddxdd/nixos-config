{
  lib,
  config,
  pkgs,
  ...
}@args:
let
  serviceHardenArgs = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RemoveIPC = true;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = [
      "@system-service"
      # Route-chain and OpenJ9 require @resources calls.
      "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
    ];
  };
  realtimeArgs = {
    CPUSchedulingPolicy = "fifo";
    CPUSchedulingPriority = 99;
    IOSchedulingClass = "realtime";
  };
in
{
  options.lantian.harden = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          options = {
            enable = lib.mkOption {
              type = lib.types.enum [
                true
                false
                "network"
              ];
              default = false;
              description = ''
                Whether to apply service hardening. Confinement is controlled
                separately by enableConfinement. The value
                "network" selects the preset for services managing host networking.
                Presets retain their mkOptionDefault priority, so explicit service
                settings and confinement defaults still take precedence.
              '';
            };

            enableConfinement = lib.mkOption {
              type = lib.types.bool;
              default = config.enable != false;
              defaultText = lib.literalExpression "enable != false";
              description = ''
                Whether to enable NixOS confinement for this service. By default
                this follows enable, but it can also enable confinement on its own.
                Disabling it does not disable hardening, resource binds or ordering
                when enable is set.
              '';
            };

            realtime = lib.mkEnableOption "the realtime scheduling preset independently of hardening and confinement";
            passwd = lib.mkEnableOption "read-only passwd/group binds from services.userborn.passwordFilesLocation";
            secret = lib.mkEnableOption "a read-only bind of the entire host /run directory";
            mysql = lib.mkEnableOption "a read-only /run/mysqld bind and ordering after mysql.service";
            postgresql = lib.mkEnableOption "a read-only /run/postgresql bind and ordering after postgresql.service";

            redis = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Redis instance whose /run/redis-<name> directory is bound read-only
                into confinement, with ordering after redis-<name>.service.
                An empty name selects /run/redis and redis.service.
              '';
            };

            etc = lib.mkOption {
              type = lib.types.attrsOf (lib.types.either (lib.types.enum [ true ]) lib.types.path);
              default = { };
              example = lib.literalExpression ''
                {
                  "nsswitch.conf" = true;
                  "app/config" = ./config;
                }
              '';
              description = ''
                Read-only files in the service's /etc, keyed by relative paths
                as in environment.etc. A true value uses environment.etc.<name>.source
                when defined, otherwise the host /etc/<name>. A file path binds
                that source at /etc/<name>. Standard identity, resolver, CA, hosts
                and timezone entries are provided by default.
              '';
            };
          };

          config.etc = lib.mapAttrs (_: lib.mkDefault) {
            machine-id = true;
            "resolv.conf" = true;
            "ssl/certs/ca-certificates.crt" = args.config.security.pki.caBundle;
            hosts = true;
            localtime = "${pkgs.tzdata}/share/zoneinfo/${args.config.time.timeZone}";
            zoneinfo = true;
          };
        }
      )
    );
    default = { };
    description = "Per-service hardening, confinement and realtime scheduling.";
  };

  config._module.args = {
    inherit serviceHardenArgs realtimeArgs;
  };

  config.assertions = lib.mapAttrsToList (name: service: {
    assertion = !service.confinement.enable || service.confinement.fullUnit;
    message = "${name}: confinement.enable requires confinement.fullUnit = true";
  }) config.systemd.services;

  config.systemd.services = lib.mapAttrs (
    _: cfg:
    let
      redisName = "redis" + lib.optionalString (cfg.redis != null && cfg.redis != "") "-${cfg.redis}";
    in
    lib.mkIf (cfg.enable != false || cfg.enableConfinement || cfg.realtime) (
      lib.mkMerge [
        (lib.mkIf (cfg.enable != false || cfg.enableConfinement) {
          after =
            lib.optional cfg.mysql "mysql.service"
            ++ lib.optional cfg.postgresql "postgresql.service"
            ++ lib.optional (cfg.redis != null) "${redisName}.service";
          serviceConfig = lib.mkMerge [
            (lib.mkIf (cfg.enable != false) (
              lib.mapAttrs (_: lib.mkOptionDefault) (
                if cfg.enable == "network" then
                  serviceHardenArgs
                  // {
                    PrivateDevices = false;
                    ProtectClock = false;
                    ProtectControlGroups = false;
                    AmbientCapabilities = [
                      "CAP_NET_ADMIN"
                      "CAP_NET_BIND_SERVICE"
                      "CAP_NET_RAW"
                    ];
                    CapabilityBoundingSet = [
                      "CAP_NET_ADMIN"
                      "CAP_NET_BIND_SERVICE"
                      "CAP_NET_RAW"
                    ];
                    RestrictAddressFamilies = [
                      "AF_UNIX"
                      "AF_INET"
                      "AF_INET6"
                      "AF_NETLINK"
                    ];
                    SystemCallFilter = [ ];
                  }
                else
                  serviceHardenArgs
              )
            ))
            {
              BindReadOnlyPaths = map (import ../../helpers/fn/systemd.nix { }).escapeMountPath (
                lib.optionals cfg.passwd [
                  "${config.services.userborn.passwordFilesLocation}/passwd:/etc/passwd"
                  "${config.services.userborn.passwordFilesLocation}/group:/etc/group"
                ]
                ++ lib.optional cfg.secret "/run"
                ++ lib.optional cfg.mysql "/run/mysqld"
                ++ lib.optional cfg.postgresql "/run/postgresql"
                ++ lib.optional (cfg.redis != null) "/run/${redisName}"
                ++ lib.mapAttrsToList (
                  name: source:
                  if source == true then
                    let
                      # Declared but undefined NixOS options throw when forced.
                      etcSource = builtins.tryEval (config.environment.etc.${name}.source or null);
                    in
                    if etcSource.success && etcSource.value != null then
                      "${etcSource.value}:/etc/${name}"
                    else
                      "/etc/${name}"
                  else
                    "${source}:/etc/${name}"
                ) cfg.etc
              );
            }
          ];
          confinement = {
            enable = cfg.enableConfinement;
            fullUnit = true;
          };
        })
        (lib.mkIf cfg.realtime {
          serviceConfig = lib.mapAttrs (_: lib.mkOptionDefault) realtimeArgs;
        })
      ]
    )
  ) config.lantian.harden;
}
