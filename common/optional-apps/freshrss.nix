{ config, pkgs, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
in
{
  services.nginx.virtualHosts."rss.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = "/var/www/rss.lantian.pub/p";
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
}
