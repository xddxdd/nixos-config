{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
  virtualisation.oci-containers.containers = {
    asf = {
      image = "justarchi/archisteamfarm:released";
      ports = [
        "${thisHost.ltnet.IPv4}:13242:1242"
      ];
      volumes = [
        "/var/lib/asf:/app/config"
      ];
    };
  };

  services.nginx.virtualHosts."asf.lantian.pub" = {
    listen = nginxHelper.listen443;
    locations = nginxHelper.addCommonLocationConf {
      "/".extraConfig = nginxHelper.locationOauthConf + ''
        proxy_pass http://${thisHost.ltnet.IPv4}:13242;
      '' + nginxHelper.locationProxyConf;
      "~* /Api/NLog".extraConfig = nginxHelper.locationOauthConf + ''
        proxy_pass http://${thisHost.ltnet.IPv4}:13242;
        proxy_http_version 1.1;
        proxy_set_header Connection "upgrade";
        proxy_set_header Upgrade $http_upgrade;
      '' + nginxHelper.locationProxyConf;
    };
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.noIndex;
  };
}
