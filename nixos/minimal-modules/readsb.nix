{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
  portOrList = lib.types.either lib.types.port (lib.types.listOf lib.types.port);
  numOrStr = lib.types.either lib.types.number lib.types.str;

  valueToStr =
    v: if builtins.isList v then builtins.concatStringsSep "," (map toString v) else toString v;

  mkFlagOption =
    default:
    lib.mkOption {
      type = lib.types.bool;
      inherit default;
    };

  mkValueOption =
    type:
    lib.mkOption {
      type = lib.types.nullOr type;
      default = null;
    };

  mkPortOption = mkValueOption portOrList;
  mkNumOption = mkValueOption numOrStr;

  readsbOptions = {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create a systemd service for this readsb instance.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.readsb;
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "readsb";
        description = "User to run the service as.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "readsb";
        description = "Group to run the service as.";
      };

      enableNetworking = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to pass `--net`.";
      };

      uuidFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path passed to `--uuid-file`.";
      };

      mlat = mkFlagOption false;
      forwardMlat = mkFlagOption false;
      forwardMlatSbs = mkFlagOption false;
      dbFileLt = mkFlagOption false;
      netSbsReduce = mkFlagOption false;
      statsRange = mkFlagOption false;

      latitude = mkValueOption numOrStr;
      longitude = mkValueOption numOrStr;
      latitudeFile = mkValueOption lib.types.str;
      longitudeFile = mkValueOption lib.types.str;

      writeJson = mkValueOption lib.types.str;
      writeState = mkValueOption lib.types.str;
      jsonReliable = mkValueOption lib.types.int;
      jsonTraceInterval = mkValueOption lib.types.int;

      netBindAddress = mkValueOption lib.types.str;
      netJsonPort = mkPortOption;
      netRawInputPort = mkPortOption;
      netRawOutputPort = mkPortOption;
      netBaseStationOutputPort = mkPortOption;
      netBaseStationInputPort = mkPortOption;
      netBaseStationJaeroInputPort = mkPortOption;
      netBeastInputPort = mkPortOption;
      netBeastOutputPort = mkPortOption;
      netBeastReduceOutPort = mkPortOption;
      netApiPort = mkPortOption;
      netApiPortFile = mkValueOption lib.types.str;

      netHeartbeat = mkValueOption lib.types.int;
      jaeroTimeout = mkValueOption lib.types.int;
      netBeastReduceInterval = mkNumOption;
      netRoIntervalBeastReduce = mkNumOption;

      heatmapDir = mkValueOption lib.types.str;
      heatmap = mkValueOption lib.types.int;

      dbFile = mkValueOption lib.types.str;
      dbFileTimeout = mkValueOption lib.types.int;

      deviceType = mkValueOption lib.types.str;
      device = mkValueOption lib.types.str;
      gain = mkValueOption numOrStr;
      ppm = mkValueOption lib.types.number;

      netConnector = mkValueOption (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              host = mkValueOption lib.types.str;
              port = mkValueOption numOrStr;
              protocol = mkValueOption lib.types.str;
            };
          }
        )
      );

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  buildArgs =
    cfg:
    lib.flatten [
      (lib.optional cfg.enableNetworking "--net")
      (lib.optional cfg.mlat "--mlat")
      (lib.optional cfg.forwardMlat "--forward-mlat")
      (lib.optional cfg.forwardMlatSbs "--forward-mlat-sbs")
      (lib.optional cfg.dbFileLt "--db-file-lt")
      (lib.optional cfg.netSbsReduce "--net-sbs-reduce")
      (lib.optional cfg.statsRange "--stats-range")

      (arg' "--uuid-file" cfg.uuidFile)
      (arg' "--write-json" cfg.writeJson)
      (arg' "--write-state" cfg.writeState)
      (arg' "--json-reliable" cfg.jsonReliable)
      (arg' "--json-trace-interval" cfg.jsonTraceInterval)
      (arg' "--net-bind-address" cfg.netBindAddress)
      (arg' "--net-json-port" cfg.netJsonPort)
      (arg' "--net-ri-port" cfg.netRawInputPort)
      (arg' "--net-ro-port" cfg.netRawOutputPort)
      (arg' "--net-sbs-port" cfg.netBaseStationOutputPort)
      (arg' "--net-sbs-in-port" cfg.netBaseStationInputPort)
      (arg' "--net-sbs-jaero-in-port" cfg.netBaseStationJaeroInputPort)
      (arg' "--net-bi-port" cfg.netBeastInputPort)
      (arg' "--net-bo-port" cfg.netBeastOutputPort)
      (arg' "--net-beast-reduce-out-port" cfg.netBeastReduceOutPort)
      (arg' "--net-api-port" cfg.netApiPort)
      (arg' "--net-api-port-file" cfg.netApiPortFile)
      (arg' "--net-heartbeat" cfg.netHeartbeat)
      (arg' "--jaero-timeout" cfg.jaeroTimeout)
      (arg' "--net-beast-reduce-interval" cfg.netBeastReduceInterval)
      (arg' "--net-ro-interval-beast-reduce" cfg.netRoIntervalBeastReduce)
      (arg' "--heatmap-dir" cfg.heatmapDir)
      (arg' "--heatmap" cfg.heatmap)
      (arg' "--db-file" cfg.dbFile)
      (arg' "--db-file-timeout" cfg.dbFileTimeout)
      (arg' "--device-type" cfg.deviceType)
      (arg' "--device" cfg.device)
      (arg' "--gain" cfg.gain)
      (arg' "--ppm" cfg.ppm)
      (
        if cfg.latitudeFile != null then
          [ "--lat=$(cat ${lib.escapeShellArg cfg.latitudeFile})" ]
        else
          (arg' "--lat" cfg.latitude)
      )
      (
        if cfg.longitudeFile != null then
          [ "--lon=$(cat ${lib.escapeShellArg cfg.longitudeFile})" ]
        else
          (arg' "--lon" cfg.longitude)
      )

      (lib.optionals (cfg.netConnector != null) (map netConnectorToStr cfg.netConnector))
      cfg.extraOptions
    ];

  arg' = name: value: lib.optionals (value != null) [ "${name}=${valueToStr value}" ];

  netConnectorToStr = conn: "--net-connector=${conn.host},${toString conn.port},${conn.protocol}";

  mkInstance =
    name: cfg:
    lib.nameValuePair "readsb-${name}" {
      description = "readsb ADS-B receiver (${name})";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        exec ${lib.getExe cfg.package} ${lib.concatStringsSep " " (buildArgs cfg)}
      '';

      serviceConfig = LT.serviceHarden // {
        PrivateDevices = false;
        RestrictAddressFamilies = "";
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        RestartSec = "5";

        # FIXME: workaround for RTL SDR permission error
        AmbientCapabilities = [ "CAP_DAC_OVERRIDE" ];
        CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];
      };
    };
in
{
  options.services.readsb = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule readsbOptions);
    default = { };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.services.readsb != { }) {
      users.users.readsb = {
        group = "readsb";
        isSystemUser = true;
      };
      users.groups.readsb = { };
    })
    {
      systemd.services = lib.mapAttrs' mkInstance config.services.readsb;
    }
  ];
}
