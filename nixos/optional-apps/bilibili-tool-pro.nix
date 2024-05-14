_: {
  virtualisation.oci-containers.containers.bilibili-tool-pro = {
    extraOptions = [
      "--pull"
      "always"
    ];
    image = "ghcr.io/raywangqvq/bilibili_tool_pro";
    environment = {
      Ray_DailyTaskConfig__Cron = "0 15 * * *";
      # Ray_LiveLotteryTaskConfig__Cron = "0 22 * * *";
      # Ray_UnfollowBatchedTaskConfig__Cron = "0 6 1 * *";
      # Ray_VipBigPointConfig__Cron = "7 1 * * *";
      # Ray_LiveFansMedalTaskConfig__Cron = "5 0 * * *";
    };
    volumes = [
      "/var/lib/bilibili-tool-pro/appsettings.json:/app/appsettings.json"
      "/var/lib/bilibili-tool-pro/cookies.json:/app/cookies.json"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/bilibili-tool-pro 755 root root"
    "f /var/lib/bilibili-tool-pro/appsettings.json 755 root root - {}"
    "f /var/lib/bilibili-tool-pro/cookies.json 755 root root - {}"
  ];
}
