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
    # Public peer-finder endpoint
    lantian.firewall.zones = {
      WAN.tcpPorts."${LT.portStr.DN42Peerfinder}".type = "local";
    };

    systemd.services.dn42-peerfinder = {
      description = "DN42 PeerFinder";
      after = [ "network.target" ];
      requires = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        LISTEN_PORT = LT.portStr.DN42Peerfinder;
        SECRET_KEY_FILE = "%d/secret";
        LANG = "C.UTF-8";
      };

      path = [ pkgs.iputils ];
      serviceConfig = {
        LoadCredential = [ "secret:${config.services.dn42-peerfinder.secretFile}" ];
        ExecStart = lib.getExe pkgs.dn42-peerfinder;

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

    lantian.harden."dn42-peerfinder".enable = true;

    users.users.dn42-peerfinder = {
      group = "dn42-peerfinder";
      isSystemUser = true;
    };
    users.groups.dn42-peerfinder = { };
  };
}
