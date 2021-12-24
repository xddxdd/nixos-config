{ pkgs, config, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
  services.resilio = {
    enable = true;
    enableWebUI = true;
    checkForUpdates = false;
    deviceName = config.networking.hostName;
    directoryRoot = "/nix/persistent/media";
    httpListenPort = 13900;
    # Authentication is done by nginx
    httpLogin = "user";
    httpPass = "pass";
  };

  systemd.tmpfiles.rules = [
    "d /nix/persistent/media 755 rslsync rslsync"
  ];

  services.nginx.virtualHosts."resilio-${config.networking.hostName}.lantian.pub" = {
    listen = nginxHelper.listen443;
    locations = nginxHelper.addCommonLocationConf {
      "/".extraConfig = nginxHelper.locationOauthConf + ''
        proxy_pass http://[::1]:13900;
        proxy_set_header Authorization "Basic dXNlcjpwYXNz";
      '' + nginxHelper.locationProxyConf;
    };
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.noIndex;
  };
}
