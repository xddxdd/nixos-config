{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.genshin-cockpy;
in {
  lantian.netns.genshin-cockpy = {
    ipSuffix = "25";
    announcedIPv4 = [
      "198.19.0.25"
    ];
    birdBindTo = ["genshin-cockpy.service"];
  };

  systemd.services.genshin-cockpy = netns.bind {
    description = "Genshin cockpy Server";
    wantedBy = ["multi-user.target"];
    serviceConfig =
      LT.serviceHarden
      // {
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
        Restart = "always";
        RestartSec = "3";
        User = "genshin-cockpy";
        Group = "genshin-cockpy";
        RuntimeDirectory = "genshin-cockpy";
        WorkingDirectory = "/run/genshin-cockpy";
        ExecStart = "${pkgs.cockpy}/bin/cockpy";
      };
  };

  users.users.genshin-cockpy = {
    group = "genshin-cockpy";
    isSystemUser = true;
  };
  users.groups.genshin-cockpy = {};
}
