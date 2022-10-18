{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  age.secrets.waline-env.file = pkgs.secrets + "/waline-env.age";

  virtualisation.oci-containers.containers = {
    waline = {
      extraOptions = [ "--pull" "always" ];
      image = "lizheming/waline";
      ports = [ "127.0.0.1:${LT.portStr.Waline}:8360" ];
      environmentFiles = [ config.age.secrets.waline-env.path ];
    };
  };

  services.nginx.virtualHosts."comments.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/".extraConfig = ''
        proxy_pass http://127.0.0.1:${LT.portStr.Waline};
        proxy_set_header REMOTE-HOST $remote_addr;
      '' + LT.nginx.locationProxyConf;
      "= /".return = "302 /ui/";
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
