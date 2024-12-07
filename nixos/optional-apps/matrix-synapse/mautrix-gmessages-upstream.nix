{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.mautrix-gmessages;
  dataDir = "/var/lib/mautrix-gmessages";
  registrationFile = "${dataDir}/gmessages-registration.yaml";
  settingsFile = "${dataDir}/config.json";
  settingsFileUnsubstituted = settingsFormat.generate "mautrix-gmessages-config-unsubstituted.json" cfg.settings;
  settingsFormat = pkgs.formats.json { };
  appservicePort = 29336;

  mkDefaults = lib.mapAttrsRecursive (_n: v: lib.mkDefault v);
  defaultConfig = {
    homeserver.address = "http://localhost:8448";
    appservice = {
      hostname = "[::]";
      port = appservicePort;
      database.type = "sqlite3";
      database.uri = "${dataDir}/mautrix-gmessages.db";
      id = "gmessages";
      bot.username = "gmessagesbot";
      bot.displayname = "Google Messages Bridge Bot";
      as_token = "";
      hs_token = "";
      username_template = "gmessages_{{.}}";
    };
    bridge = {
      command_prefix = "!gmsg";
      permissions."*" = "relay";
      relay.enabled = true;
    };
    network = {
      displayname_template = "{{or .FullName .PhoneNumber}}";
      device_meta = {
        os = "mautrix-gmessages";
        browser = "OTHER";
        type = "TABLET";
      };
      aggressive_reconnect = false;
      initial_chat_sync_count = 25;
    };
    logging = {
      min_level = "info";
      writers = lib.singleton {
        type = "stdout";
        format = "pretty-colored";
        time_format = " ";
      };
    };
  };

in
{
  options.services.mautrix-gmessages = {
    enable = lib.mkEnableOption "mautrix-gmessages, a puppeting/relaybot bridge between Matrix and Google Messages";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mautrix-gmessages;
      description = ''
        The mautrix-gmessages package to use.
      '';
    };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = defaultConfig;
      description = ''
        {file}`config.yaml` configuration as a Nix attribute set.
        Configuration options should match those described in
        [example-config.yaml](https://github.com/mautrix/gmessages/blob/main/pkg/connector/example-config.yaml).
        Secret tokens should be specified using {option}`environmentFile`
        instead of this world-readable attribute set.
      '';
      example = {
        appservice = {
          database = {
            type = "postgres";
            uri = "postgresql:///mautrix_gmessages?host=/run/postgresql";
          };
          id = "gmessages";
          ephemeral_events = false;
        };
        bridge = {
          displayname_template = "{{or .FullName .PhoneNumber}}";
          device_meta = {
            os = "mautrix-gmessages";
            browser = "OTHER";
            type = "TABLET";
          };
          aggressive_reconnect = false;
          initial_chat_sync_count = 25;
        };
      };
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File containing environment variables to be passed to the mautrix-gmessages service,
        in which secret tokens can be specified securely by optionally defining a value for
        `MAUTRIX_GMESSAGES_BRIDGE_LOGIN_SHARED_SECRET`.
      '';
    };

    serviceDependencies = lib.mkOption {
      type = with lib.types; listOf str;
      default = lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit;
      defaultText = lib.literalExpression ''
        optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnits
      '';
      description = ''
        List of Systemd services to require and wait for when starting the application service.
      '';
    };

    registerToSynapse = lib.mkOption {
      type = lib.types.bool;
      default = config.services.matrix-synapse.enable;
      defaultText = lib.literalExpression "config.services.matrix-synapse.enable";
      description = ''
        Whether to add the bridge's app service registration file to
        `services.matrix-synapse.settings.app_service_config_files`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.mautrix-gmessages = {
      isSystemUser = true;
      group = "mautrix-gmessages";
      home = dataDir;
      description = "Mautrix-gmessages bridge user";
    };

    users.groups.mautrix-gmessages = { };

    services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      settings.app_service_config_files = [ registrationFile ];
    };
    systemd.services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      serviceConfig.SupplementaryGroups = [ "mautrix-gmessages" ];
    };

    services.mautrix-gmessages.settings = lib.mkMerge (
      map mkDefaults [
        defaultConfig
        # Note: this is defined here to avoid the docs depending on `config`
        { homeserver.domain = config.services.matrix-synapse.settings.server_name; }
      ]
    );

    systemd.services.mautrix-gmessages = {
      description = "Mautrix-gmessages Service - A gmessages bridge for Matrix";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;

      preStart = ''
        # substitute the settings file by environment variables
        # in this case read from EnvironmentFile
        test -f '${settingsFile}' && rm -f '${settingsFile}'
        old_umask=$(umask)
        umask 0177
        ${pkgs.envsubst}/bin/envsubst \
          -o '${settingsFile}' \
          -i '${settingsFileUnsubstituted}'
        umask $old_umask

        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${cfg.package}/bin/mautrix-gmessages \
            --generate-registration \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi
        chmod 640 ${registrationFile}

        umask 0177
        # 1. Overwrite registration tokens in config
        # 2. If environment variable MAUTRIX_GMESSAGES_BRIDGE_LOGIN_SHARED_SECRET
        #    is set, set it as the login shared secret value for the configured
        #    homeserver domain.
        ${pkgs.yq}/bin/yq -s '.[0].appservice.as_token = .[1].as_token
          | .[0].appservice.hs_token = .[1].hs_token
          | .[0]
          | if env.MAUTRIX_GMESSAGES_BRIDGE_LOGIN_SHARED_SECRET then .bridge.login_shared_secret_map.[.homeserver.domain] = env.MAUTRIX_GMESSAGES_BRIDGE_LOGIN_SHARED_SECRET else . end' \
          '${settingsFile}' '${registrationFile}' > '${settingsFile}.tmp'
        mv '${settingsFile}.tmp' '${settingsFile}'
        umask $old_umask
      '';

      serviceConfig = {
        User = "mautrix-gmessages";
        Group = "mautrix-gmessages";
        EnvironmentFile = cfg.environmentFile;
        StateDirectory = baseNameOf dataDir;
        WorkingDirectory = dataDir;
        ExecStart = ''
          ${cfg.package}/bin/mautrix-gmessages \
          --config='${settingsFile}' \
          --registration='${registrationFile}'
        '';
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "30s";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
        UMask = 27;
      };
      restartTriggers = [ settingsFileUnsubstituted ];
    };
  };
  meta.maintainers = with lib.maintainers; [ xddxdd ];
}