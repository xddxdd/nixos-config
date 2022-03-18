{ config, pkgs, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  virtualisation.oci-containers.containers = {
    asf = {
      extraOptions = [ "--pull" "always" ];
      image = "justarchi/archisteamfarm:released";
      ports = [
        "${LT.this.ltnet.IPv4}:${LT.portStr.ASF}:1242"
      ];
      volumes = [
        "/var/lib/asf:/app/config"
      ];
    };
  };

  services.nginx.virtualHosts."asf.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addNoIndexLocationConf {
      "/".extraConfig = LT.nginx.locationOauthConf + ''
        proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.ASF};
      '' + LT.nginx.locationProxyConf;
      "~* /Api/NLog".extraConfig = LT.nginx.locationOauthConf + ''
        proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.ASF};
        proxy_http_version 1.1;
        proxy_set_header Connection "upgrade";
        proxy_set_header Upgrade $http_upgrade;
      '' + LT.nginx.locationProxyConf;
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
