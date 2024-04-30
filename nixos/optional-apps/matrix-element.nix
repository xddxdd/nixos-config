{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  lantian.nginxVhosts."element.lantian.pub" = {
    listenHTTP.enable = true;
    root = builtins.toString pkgs.element-web;
    locations = {
      "/" = {
        index = "index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
    };

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
