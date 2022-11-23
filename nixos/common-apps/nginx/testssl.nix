{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;
in
{
  services.nginx.virtualHosts = {
    "buypass-ssl.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      root = "/nix/persistent/sync-servers/www/buypass-ssl.lantian.pub";
      locations."/".index = "testssl.htm";
      extraConfig = LT.nginx.makeSSL "buypass-ssl.lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
    "zerossl.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      root = "/nix/persistent/sync-servers/www/zerossl.lantian.pub";
      locations."/".index = "testssl.htm";
      extraConfig = LT.nginx.makeSSL "zerossl.lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };
}
