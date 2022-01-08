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
      "= /".extraConfig = ''
        autoindex on;
        add_after_body /autoindex.html;
      '';
      "/hobby-net".extraConfig = ''
        autoindex on;
        add_after_body /autoindex.html;
      '';
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

  systemd.tmpfiles.rules = [
    "L+ ${labRoot}/dngzwxdq - - - - ${pkgs.nur.repos.xddxdd.dngzwxdq}"
    "L+ ${labRoot}/dnyjzsxj - - - - ${pkgs.nur.repos.xddxdd.dnyjzsxj}"
  ];
}
