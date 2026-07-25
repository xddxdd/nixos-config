{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
{
  options.services.dn42-peerfinder = {
    secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "UUID of the peerfinder service";
    };
  };

  config = lib.mkIf (config.services.dn42-peerfinder.secretFile != null) {
    systemd.services.dn42-peerfinder = {
      description = "DN42 PeerFinder";
      after = [ "network.target" ];
      requires = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        LISTEN_PORT = LT.portStr.DN42Peerfinder;
        SECRET_KEY_FILE = config.services.dn42-peerfinder.secretFile;
      };

      path = [ pkgs.iputils ];
      serviceConfig = LT.serviceHarden // {
        ExecStart = "${lib.getExe pkgs.python3} ${LT.sources.dn42-peerfinder-client.src}";

        # Needed by ping
        AmbientCapabilities = [ "CAP_NET_RAW" ];
        CapabilityBoundingSet = [ "CAP_NET_RAW" ];
        SystemCallFilter = [ ];

        User = "dn42-peerfinder";
        Group = "dn42-peerfinder";

        Restart = "always";
        RestartSec = "5";
        CPUQuota = "10%";
      };
    };

    users.users.dn42-peerfinder = {
      group = "dn42-peerfinder";
      isSystemUser = true;
    };
    users.groups.dn42-peerfinder = { };
  };
}
