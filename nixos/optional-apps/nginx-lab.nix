{ config, pkgs, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
  labRoot = "/var/www/lab.lantian.pub";
in
{
  services.nginx.virtualHosts."lab.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = labRoot;
    locations = LT.nginx.addCommonLocationConf {
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
      "= /robots.txt".extraConfig = ''
        alias ${../files/robots-block.txt};
      '';
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
    group = config.services.nginx.group;
  };

  systemd.services.fcgiwrap.serviceConfig = LT.serviceHarden // {
    ReadWritePaths = [
      "/var/www/lab.lantian.pub"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ ${labRoot}/dngzwxdq - - - - ${pkgs.dngzwxdq}"
    "L+ ${labRoot}/dnyjzsxj - - - - ${pkgs.dnyjzsxj}"
    "L+ ${labRoot}/glibc-for-debian-10-on-openvz - - - - ${pkgs.glibc-debian-openvz-files}"
  ];
}
