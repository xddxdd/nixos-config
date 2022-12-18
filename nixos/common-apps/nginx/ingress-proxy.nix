{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  services.nginx.virtualHosts = {
    "comments.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = ''
          proxy_pass http://${LT.hosts."oneprovider".ltnet.IPv4}:${LT.portStr.Waline};
          proxy_set_header REMOTE-HOST $remote_addr;
        '' + LT.nginx.locationProxyConf;
        "= /".return = "302 /ui/";
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };
}
