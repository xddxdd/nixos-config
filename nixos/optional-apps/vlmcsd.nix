{
  pkgs,
  LT,
  config,
  ...
}:
{
  lantian.netns.kms = {
    ipSuffix = "88";
    announcedIPv4 = [
      "198.19.0.252"
      "10.127.10.252"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::1688"
      "fd10:127:10:2547::1688"
    ];
    birdBindTo = [ "vlmcsd.service" ];
  };

  systemd.services.vlmcsd = config.lantian.netns.kms.bind {
    description = "Vlmcsd";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "forking";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur.repos.linyinfeng.vlmcsd}/bin/vlmcsd";
      DynamicUser = true;
    };
  };
}
