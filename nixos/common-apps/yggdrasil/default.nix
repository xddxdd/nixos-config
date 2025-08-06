{
  lib,
  LT,
  config,
  options,
  ...
}:

let
  publicPeers = lib.importJSON ./public-peers.json;
  regionsToServers =
    regions: lib.flatten (builtins.map (region: publicPeers."${region}" or [ ]) regions);

  regionMappings = {
    "CN" = [
      "hong-kong"
      "japan"
      "singapore"
    ];
    "LU" = [
      "luxembourg"
      "germany"
      "france"
    ];
    "CH" = [
      "austria"
      "germany"
      "france"
    ];
    "US" = [ "united-states" ];
    "DE" = [ "germany" ];
    "JP" = [ "japan" ];
    "NO" = [ "sweden" ];
  };
in
{
  options.services.yggdrasil.regions = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = regionMappings."${LT.this.city.country}";
    description = "Connect to servers in these regions by default.";
  };

  config = {
    services.yggdrasil = {
      enable = true;
      extraArgs = [
        "-loglevel"
        "warn"
      ];
      settings = {
        Listen = [ ];

        MulticastInterfaces = [
          {
            Regex = "ztje7axwd2";
            Beacon = true;
            Listen = true;
            Port = LT.port.Yggdrasil.Multicast;
          }
        ];

        IfName = "yggdrasil";
        NodeInfoPrivacy = true;

        Peers = regionsToServers config.services.yggdrasil.regions;
      };
      persistentKeys = true;
    };

    systemd.services.yggdrasil.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "yggdrasil";
      Group = lib.mkForce "yggdrasil";
    };

    users.users.yggdrasil = {
      group = "yggdrasil";
      isSystemUser = true;
    };
    users.groups.yggdrasil = { };
  };
}
