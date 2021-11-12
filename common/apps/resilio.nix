{ pkgs, config, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
  services.resilio = {
    enable = true;
    enableWebUI = true;
    deviceName = config.networking.hostName;
    httpListenPort = 13900;
  };

  services.nginx.virtualHosts."resilio.lantian.pub" = {
    listen = nginxHelper.listen443;
    locations = nginxHelper.addCommonLocationConf {
      "/".extraConfig = nginxHelper.locationOauthConf + ''
        proxy_pass http://[::1]:13900;
      '' + nginxHelper.locationProxyConf;
    };
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true;
  };
}
