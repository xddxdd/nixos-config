{ config, pkgs, ... }:

{
  age.secrets.genshin-impact-cookies.file = ../../secrets/genshin-impact-cookies.age;

  systemd.services.genshin-helper = {
    serviceConfig.Type = "oneshot";
    script = "${pkgs.nur.repos.xddxdd.genshin-checkin-helper}/bin/genshin-checkin-helper-once";
    serviceConfig = {
      EnvironmentFile = config.age.secrets.genshin-impact-cookies.path;
    };
    unitConfig = {
      After = "network.target";
    };
  };

  systemd.timers.genshin-helper = {
    wantedBy = [ "timers.target" ];
    partOf = [ "genshin-helper.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00 UTC";
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "genshin-helper.service";
    };
  };
}
