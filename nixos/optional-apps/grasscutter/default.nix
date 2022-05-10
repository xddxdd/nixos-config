{ pkgs, lib, config, utils, ... }:

# Update config.example.json on grasscutter update!

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  netns = LT.netns {
    name = "grasscutter";
    announcedIPv4 = [
      "172.22.76.107"
      "172.18.0.226"
      "10.127.10.226"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::26"
      "fd10:127:10:2547::26"
    ];
    birdBindTo = [ "grasscutter.service" ];
  };

  originalConfig = lib.importJSON (./. + "/config.${pkgs.grasscutter.version}.json");

  cfg =
    let
      publicIP = "172.22.76.107";
    in
    lib.recursiveUpdate originalConfig {
      GameServer.PublicIp = publicIP;
      DispatchServer.PublicIp = publicIP;
    };
in
{
  systemd.services = netns.setup // {
    grasscutter = netns.bind {
      wantedBy = [ "multi-user.target" ];
      after = [ "grasscutter-mongodb.service" ];
      requires = [ "grasscutter-mongodb.service" ];
      script =
        let
          stdinScript = pkgs.writeShellScript "stdin.sh" ''
            echo "en"
            sleep infinity
          '';
        in
        ''
          ${utils.genJqSecretsReplacementSnippet
            cfg
            "/var/lib/grasscutter/config.json"}

          ${stdinScript} | ${pkgs.grasscutter}/bin/grasscutter
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

    grasscutter-mongodb =
      let
        dbPath = "/var/lib/grasscutter-mongodb";
        pidFile = "/run/grasscutter-mongodb/mongodb.pid";
        user = "container";

        mongoCfg = pkgs.writeText "mongodb.conf"
          ''
            net.bindIp: 127.0.0.1
            systemLog.destination: syslog
            storage.dbPath: ${dbPath}
          '';
      in
      netns.bind {
        wantedBy = [ "grasscutter.service" ];
        after = [ "network.target" ];

        serviceConfig = LT.serviceHarden // {
          ExecStart = "${pkgs.mongodb}/bin/mongod --config ${mongoCfg} --fork --pidfilepath ${pidFile}";
          PIDFile = pidFile;
          Type = "forking";
          TimeoutStartSec = 120; # intial creating of journal can take some time
          PermissionsStartOnly = true;

          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

          StateDirectory = "grasscutter-mongodb";
          RuntimeDirectory = "grasscutter-mongodb";
          User = "container";
          Group = "container";
        };

        preStart = ''
          rm ${dbPath}/mongod.lock || true
          if ! test -e ${dbPath}; then
              install -d -m0700 -o ${user} ${dbPath}
              # See postStart!
              touch ${dbPath}/.first_startup
          fi
          if ! test -e ${pidFile}; then
              install -D -o ${user} /dev/null ${pidFile}
          fi
        '';
      };
  };
}
