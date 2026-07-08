{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
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

  mlatOptions = {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create a systemd service for this mlat-client instance.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nur-xddxdd.mlat-client;
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "mlat-client";
        description = "User to run the service as.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "mlat-client";
        description = "Group to run the service as.";
      };

      inputType = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "dump1090"
          "beast"
          "radarcape_12mhz"
          "radarcape_gps"
          "radarcape"
          "sbs"
          "avrmlat"
        ];
        default = "auto";
        description = "Sets the input receiver type.";
      };

      inputConnect = mkValueOption lib.types.str;

      results = mkValueOption (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              mode = lib.mkOption {
                type = lib.types.enum [
                  "connect"
                  "listen"
                ];
                description = " Whether to connect to a remote host or listen on a local port.";
              };
              protocol = lib.mkOption {
                type = lib.types.enum [
                  "basestation"
                  "ext_basestation"
                  "beast"
                ];
                description = "Results output protocol.";
              };
              host = mkValueOption lib.types.str;
              port = mkValueOption numOrStr;
            };
          }
        )
      );

      noAnonResults = mkFlagOption false;
      noModeacResults = mkFlagOption false;

      latitude = mkValueOption numOrStr;
      longitude = mkValueOption numOrStr;
      altitude = mkValueOption numOrStr;
      latitudeFile = mkValueOption lib.types.str;
      longitudeFile = mkValueOption lib.types.str;
      altitudeFile = mkValueOption lib.types.str;

      privacy = mkFlagOption false;

      mlatUser = mkValueOption lib.types.str;
      server = mkValueOption lib.types.str;
      noUdp = mkFlagOption false;
      uuidFile = mkValueOption lib.types.str;

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  arg' = name: value: lib.optionals (value != null) [ "${name}=${valueToStr value}" ];

  resultToStr =
    r:
    if r.mode == "connect" then
      "--results=${r.protocol},connect,${r.host}:${toString r.port}"
    else
      "--results=${r.protocol},listen,${toString r.port}";

  buildArgs =
    cfg:
    lib.flatten [
      (arg' "--input-type" cfg.inputType)
      (arg' "--input-connect" cfg.inputConnect)
      (lib.optionals (cfg.results != null) (map resultToStr cfg.results))
      (lib.optional cfg.noAnonResults "--no-anon-results")
      (lib.optional cfg.noModeacResults "--no-modeac-results")
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
      (
        if cfg.altitudeFile != null then
          [ "--alt=$(cat ${lib.escapeShellArg cfg.altitudeFile})" ]
        else
          (arg' "--alt" cfg.altitude)
      )
      (lib.optional cfg.privacy "--privacy")
      (arg' "--user" cfg.mlatUser)
      (arg' "--server" cfg.server)
      (lib.optional cfg.noUdp "--no-udp")
      (arg' "--uuid-file" cfg.uuidFile)
      cfg.extraOptions
    ];

  mkInstance =
    name: cfg:
    lib.nameValuePair "mlat-client-${name}" {
      description = "mlat-client multilateration client (${name})";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        exec ${lib.getExe cfg.package} ${lib.concatStringsSep " " (buildArgs cfg)}
      '';

      serviceConfig = LT.serviceHarden // {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        RestartSec = "5";
      };
    };
in
{
  options.services.mlat-client = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule mlatOptions);
    default = { };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.services.mlat-client != { }) {
      users.users.mlat-client = {
        group = "mlat-client";
        isSystemUser = true;
      };
      users.groups.mlat-client = { };
    })
    {
      systemd.services = lib.mapAttrs' mkInstance config.services.mlat-client;
    }
  ];
}
