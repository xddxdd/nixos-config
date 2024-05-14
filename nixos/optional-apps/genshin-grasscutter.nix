{
  pkgs,
  lib,
  LT,
  config,
  utils,
  ...
}:
let
  anycastIP = "198.19.0.27";

  netns = config.lantian.netns.genshin-grasscutter;

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
in
{
  lantian.netns.genshin-grasscutter = {
    ipSuffix = "27";
    announcedIPv4 = [ "198.19.0.27" ];
    birdBindTo = [ "grasscutter.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/grasscutter 755 container container"
    "d /var/lib/grasscutter-ferretdb 755 container container"
  ];

  systemd.services.grasscutter-ferretdb = netns.bind {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      FERRETDB_HANDLER = "sqlite";
      FERRETDB_SQLITE_URL = "file:/var/lib/grasscutter-ferretdb/";
    };
    serviceConfig = LT.serviceHarden // {
      WorkingDirectory = "/var/lib/grasscutter-ferretdb";
      StateDirectory = "grasscutter-ferretdb";
      ExecStart = "${pkgs.ferretdb}/bin/ferretdb";
      Restart = "on-failure";
      RestartSec = "3";
      User = "container";
      Group = "container";
    };
  };

  systemd.services.grasscutter = netns.bind {
    wantedBy = [ "multi-user.target" ];
    after = [ "grasscutter-ferretdb.service" ];
    requires = [ "grasscutter-ferretdb.service" ];
    script = ''
      ${utils.genJqSecretsReplacementSnippet cfg "/var/lib/grasscutter/config.json"}

      exec ${pkgs.grasscutter}/bin/grasscutter
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

      MemoryDenyWriteExecute = false;
      WorkingDirectory = "/var/lib/grasscutter";
      StateDirectory = "grasscutter";
      User = "container";
      Group = "container";
    };
  };
}
