{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  services.nginx.virtualHosts = {
    "buypass-ssl.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      root = "/var/www/buypass-ssl.lantian.pub";
      locations."/".index = "index.htm";
      extraConfig = LT.nginx.makeSSL "buypass-ssl.lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "zerossl.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      root = "/var/www/zerossl.lantian.pub";
      locations."/".index = "index.htm";
      extraConfig = LT.nginx.makeSSL "zerossl.lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/buypass-ssl.lantian.pub 755 root root"
    "d /var/www/zerossl.lantian.pub 755 root root"
  ];
}
