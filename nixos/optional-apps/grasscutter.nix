{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  ipSuffix = "27";

  originalConfig = lib.importJSON (pkgs.grasscutter + "/opt/config.example.json");

  cfg = lib.recursiveUpdate originalConfig {
    server = {
      http.accessAddress = "${LT.this.ltnet.IPv4Prefix}.${ipSuffix}";
      game = {
        enableConsole = false;
        accessAddress = "${LT.this.ltnet.IPv4Prefix}.${ipSuffix}";
      };
    };
  };
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/grasscutter 755 root root"
  ];

  containers.grasscutter = LT.container {
    name = "grasscutter";
    inherit ipSuffix;

    outerConfig = {
      bindMounts = {
        "/var/lib" = {
          hostPath = "/var/lib/grasscutter";
          isReadOnly = false;
        };
      };
    };
    innerConfig = {...}: {
      services.mongodb = {
        enable = true;
        quiet = true;
      };

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
