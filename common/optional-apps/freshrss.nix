{ config, pkgs, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };

  freshrssPath = "/var/www/rss.lantian.pub";
in
{
  services.nginx.virtualHosts."rss.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = "${freshrssPath}/p";
    locations = LT.nginx.addCommonLocationConf {
      "/" = {
        index = "index.php index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };

  systemd.services.freshrss = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.services.phpfpm.phpPackage}/bin/php ${freshrssPath}/app/actualize_script.php";
      User = config.services.nginx.user;
      Group = config.services.nginx.group;
    };
  };

  systemd.timers.freshrss = {
    wantedBy = [ "timers.target" ];
    partOf = [ "freshrss.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "freshrss.service";
    };
  };
}
