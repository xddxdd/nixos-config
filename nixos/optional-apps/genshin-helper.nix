{ config, pkgs, lib, ... }:

{
  age.secrets.genshin-impact-cookies.file = pkgs.secrets + "/genshin-impact-cookies.age";

  systemd.services.genshin-helper = {
    serviceConfig.Type = "oneshot";
    script = "${pkgs.genshin-checkin-helper}/bin/genshin-checkin-helper-once";
    serviceConfig = {
      EnvironmentFile = config.age.secrets.genshin-impact-cookies.path;
      TimeoutSec = 900;
      Restart = "on-failure";
      RestartSec = 30;
    };
    unitConfig = {
      After = "network.target";
    };
  };

  systemd.timers.genshin-helper = {
    wantedBy = [ "timers.target" ];
    partOf = [ "genshin-helper.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 14:30:00";
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "genshin-helper.service";
    };
  };
}
