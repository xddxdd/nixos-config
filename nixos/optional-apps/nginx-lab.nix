{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
  labRoot = "/var/www/lab.lantian.pub";
in
{
  services.nginx.virtualHosts."lab.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = labRoot;
    locations = LT.nginx.addCommonLocationConf
      { phpfpmSocket = config.services.phpfpm.pools.lab.socket; }
      {
        "/" = {
          index = "index.php index.html index.htm";
          tryFiles = "$uri $uri/ =404";
        };
        "= /".extraConfig = LT.nginx.locationAutoindexConf;
        "/cgi-bin/" = {
          index = "index.sh";
          extraConfig = LT.nginx.locationFcgiwrapConf;
        };
        "/glibc-for-debian-10-on-openvz".extraConfig = LT.nginx.locationAutoindexConf;
        "/hobby-net".extraConfig = LT.nginx.locationAutoindexConf;
        "/zjui-ece385-scoreboard".extraConfig = ''
          gzip off;
          brotli off;
          zstd off;
        '';
      };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  services.phpfpm.pools.lab = {
    phpPackage = pkgs.phpWithExtensions;
    inherit (config.services.nginx) user;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "ondemand";
      "pm.max_children" = "8";
      "pm.process_idle_timeout" = "10s";
      "pm.max_requests" = "1000";
      "pm.status_path" = "/php-fpm-status.php";
      "ping.path" = "/ping.php";
      "ping.response" = "pong";
      "request_terminate_timeout" = "300";
    };
  };

  services.fcgiwrap = {
    enable = true;
    inherit (config.services.nginx) user group;
  };

  systemd.services.fcgiwrap.serviceConfig = LT.serviceHarden // {
    ReadWritePaths = [
      "/var/www/lab.lantian.pub"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ ${labRoot}/dngzwxdq - - - - ${pkgs.lantianPersonal.dngzwxdq}"
    "L+ ${labRoot}/dnyjzsxj - - - - ${pkgs.lantianPersonal.dnyjzsxj}"
    "L+ ${labRoot}/glibc-for-debian-10-on-openvz - - - - ${pkgs.lantianPersonal.glibc-debian-openvz-files}"
    "L+ ${labRoot}/hobby-net - - - - /nix/persistent/sync-servers/ltnet-scripts"
    "L+ ${labRoot}/testssl.html - - - - /nix/persistent/sync-servers/www/lab.lantian.pub/testssl.htm"
  ];
}
