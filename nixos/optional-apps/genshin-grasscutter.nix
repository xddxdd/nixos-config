{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  anycastIP = "198.19.0.27";

  originalConfig = lib.importJSON (pkgs.grasscutter + "/opt/config.example.json");

  cfg = lib.recursiveUpdate originalConfig {
    account = {
      autoCreate = true;
      EXPERIMENTAL_RealPassword = true;
    };
    server = {
      http.accessAddress = anycastIP;
      game = {
        enableConsole = false;
        accessAddress = anycastIP;
      };
    };
  };
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/grasscutter 755 container container"
    "d /var/lib/mongodb-grasscutter 755 container container"
  ];

  containers.grasscutter = LT.container {
    name = "grasscutter";
    ipSuffix = "27";
    announcedIPv4 = [anycastIP];

    outerConfig = {
      bindMounts = {
        "/var/lib/grasscutter" = {
          hostPath = "/var/lib/grasscutter";
          isReadOnly = false;
        };
        "/var/lib/mongodb-grasscutter" = {
          hostPath = "/var/lib/mongodb-grasscutter";
          isReadOnly = false;
        };
      };
    };
    innerConfig = {...}: {
      services.mongodb = {
        enable = true;
        quiet = true;
        user = "container";
        dbpath = "/var/lib/mongodb-grasscutter";
      };

      systemd.services.mongodb.serviceConfig.Group = "container";

      systemd.services.grasscutter = {
        wantedBy = ["multi-user.target"];
        after = ["grasscutter-mongodb.service"];
        requires = ["grasscutter-mongodb.service"];
        script = ''
          ${utils.genJqSecretsReplacementSnippet
            cfg
            "/var/lib/grasscutter/config.json"}

          exec ${pkgs.grasscutter}/bin/grasscutter
        '';
        serviceConfig =
          LT.serviceHarden
          // {
            Type = "simple";
            Restart = "always";
            RestartSec = "3";
            AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
            CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];

            MemoryDenyWriteExecute = false;
            WorkingDirectory = "/var/lib/grasscutter";
            StateDirectory = "grasscutter";
            User = "container";
            Group = "container";
          };
      };
    };
  };
}
