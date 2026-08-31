{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
  stayrtrOptions = {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create a systemd service for this stayrtr instance.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.stayrtr;
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "stayrtr";
        description = "User to run the service as.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "stayrtr";
        description = "Group to run the service as.";
      };

      bind = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address to listen on for RTR connections.";
      };

      port = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.number lib.types.str);
        default = null;
      };

      metricsBind = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address to listen on for Prometheus metrics.";
      };

      metricsPort = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.number lib.types.str);
        default = null;
      };

      cache = lib.mkOption {
        type = lib.types.str;
        description = "Path or URL of the cache file with RPKI/ROA data.";
      };

      expire = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.number lib.types.str);
        default = null;
      };

      refresh = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.number lib.types.str);
        default = null;
      };

      retry = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.number lib.types.str);
        default = null;
      };

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  arg' = name: value: lib.optionals (value != null) [ "--${name} ${toString value}" ];

  buildArgs =
    cfg:
    lib.flatten [
      [ "--bind ${cfg.bind}:${toString cfg.port}" ]
      (lib.optionals (cfg.metricsPort != null) [
        "--metrics.addr ${cfg.metricsBind}:${toString cfg.metricsPort}"
      ])
      [ "--cache ${cfg.cache}" ]
      (arg' "rtr.expire" cfg.expire)
      (arg' "rtr.refresh" cfg.refresh)
      (arg' "rtr.retry" cfg.retry)
      cfg.extraOptions
    ];

  mkInstance =
    name: cfg:
    lib.nameValuePair "stayrtr-${name}" (
      lib.mkIf cfg.enable {
        description = "StayRTR RTR server (${name})";
        before = [ "bird.service" ];
        after = [ "network.target" ];
        requires = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${lib.getExe cfg.package} ${lib.concatStringsSep " " (buildArgs cfg)}
        '';

        serviceConfig = LT.serviceHarden // {
          Type = "simple";
          Restart = "always";
          RestartSec = "3";
          User = cfg.user;
          Group = cfg.group;
        };
      }
    );
in
{
  options.services.stayrtr = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule stayrtrOptions);
    default = { };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.services.stayrtr != { }) {
      users.users.stayrtr = {
        group = "stayrtr";
        isSystemUser = true;
      };
      users.groups.stayrtr = { };
    })
    {
      systemd.services = lib.mapAttrs' mkInstance config.services.stayrtr;
    }
  ];
}
