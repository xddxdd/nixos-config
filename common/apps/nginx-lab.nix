{ config, pkgs, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
  labRoot = "/var/www/lab.lantian.pub";
in
{
  services.nginx.virtualHosts."lab.lantian.pub" = {
    listen = nginxHelper.listen443;
    root = labRoot;
    locations = nginxHelper.addCommonLocationConf {
      "/" = {
        index = "index.php index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
      "= /".extraConfig = nginxHelper.locationAutoindexConf;
      "/cgi-bin/" = {
        index = "index.sh";
        extraConfig = nginxHelper.locationFcgiwrapConf;
      };
      "/glibc-for-debian-10-on-openvz".extraConfig = nginxHelper.locationAutoindexConf;
      "/hobby-net".extraConfig = nginxHelper.locationAutoindexConf;
      "/zjui-ece385-scoreboard".extraConfig = ''
        gzip off;
        brotli off;
        zstd off;
      '';
      "= /robots.txt".extraConfig = ''
        alias ${../files/robots-block.txt};
      '';
    };
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.noIndex;
  };

  services.fcgiwrap = {
    enable = true;
    user = config.services.nginx.user;
    group = config.services.nginx.group;
  };

  systemd.tmpfiles.rules = [
    "L+ ${labRoot}/dngzwxdq - - - - ${pkgs.nur.repos.xddxdd.dngzwxdq}"
    "L+ ${labRoot}/dnyjzsxj - - - - ${pkgs.nur.repos.xddxdd.dnyjzsxj}"
    "L+ ${labRoot}/glibc-for-debian-10-on-openvz - - - - ${pkgs.nur.repos.xddxdd.glibc-debian-openvz-files}"
  ];
}
