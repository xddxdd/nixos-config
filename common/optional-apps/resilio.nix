{ pkgs, config, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
in
{
  services.resilio = {
    enable = true;
    enableWebUI = true;
    checkForUpdates = false;
    deviceName = config.networking.hostName;
    directoryRoot = "/nix/persistent/media";
    httpListenPort = LT.port.ResilioSync;
    # Authentication is done by nginx
    httpLogin = "user";
    httpPass = "pass";
  };

  systemd.tmpfiles.rules = [
    "d /nix/persistent/media 755 rslsync rslsync"
  ];

  services.nginx.virtualHosts."resilio-${config.networking.hostName}.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {
      "/".extraConfig = LT.nginx.locationOauthConf + ''
        proxy_pass http://[::1]:${LT.portStr.ResilioSync};
        proxy_set_header Authorization "Basic dXNlcjpwYXNz";
      '' + LT.nginx.locationProxyConf;
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
