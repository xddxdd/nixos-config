{ pkgs, lib, LT, config, options, utils, inputs, ... }@args:

let
  publicPeers = lib.importJSON ./public-peers.json;
  regionsToServers = regions: lib.flatten (builtins.map (region: publicPeers."${region}" or [ ]) regions);
in
{
  options.services.yggdrasil.regions = lib.mkOption {
    type = lib.types.listOf lib.types.string;
    default = [ ];
    description = "Connect to servers in these regions by default.";
  };

  config = {
    services.yggdrasil = {
      enable = true;
      group = "wheel";
      settings = {
        Listen = [ "tls://[::]:${LT.portStr.Yggdrasil.Public}" ];

        MulticastInterfaces = [{
          Regex = "zthnhe4bol";
          Beacon = true;
          Listen = true;
          Port = LT.port.Yggdrasil.Multicast;
        }];

        IfName = "yggdrasil";
        NodeInfoPrivacy = true;

        Peers = regionsToServers config.services.yggdrasil.regions;
      };
      persistentKeys = true;
    };

    systemd.services.yggdrasil.serviceConfig = {
      ExecStart =
        lib.mkForce "${config.services.yggdrasil.package}/bin/yggdrasil -loglevel error -logto syslog -useconffile /run/yggdrasil/yggdrasil.conf";

      # Disable logging
      StandardOutput = "null";
      StandardError = "null";
    };
  };
}
