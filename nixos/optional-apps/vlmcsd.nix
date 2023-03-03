{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = LT.netns {
    name = "kms";
    announcedIPv4 = [
      "172.18.0.252"
      "10.127.10.252"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::1688"
      "fd10:127:10:2547::1688"
    ];
    birdBindTo = ["vlmcsd.service"];
  };
in {
  systemd.services =
    netns.setup
    // {
      vlmcsd = netns.bind {
        description = "Vlmcsd";
        wantedBy = ["multi-user.target"];
        serviceConfig =
          LT.serviceHarden
          // {
            Type = "forking";
            Restart = "always";
            RestartSec = "3";
            ExecStart = "${config.nur.repos.linyinfeng.vlmcsd}/bin/vlmcsd";
            DynamicUser = true;
          };
      };
    };
}
