{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  age.secrets.vaultwarden-env.file = pkgs.secrets + "/vaultwarden-env.age";

  services.vaultwarden = {
    enable = true;
    config = {
      SIGNUPS_ALLOWED = false;
      DOMAIN = "https://bitwarden.lantian.pub";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = LT.port.Vaultwarden.HTTP;
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_PORT = LT.port.Vaultwarden.Websocket;

      SMTP_HOST = config.programs.msmtp.accounts.default.host;
      SMTP_FROM = config.programs.msmtp.accounts.default.from;
      SMTP_FROM_NAME = "Vaultwarden";
      SMTP_PORT = config.programs.msmtp.accounts.default.port;
      SMTP_SSL = config.programs.msmtp.accounts.default.tls;
      SMTP_EXPLICIT_TLS = !config.programs.msmtp.accounts.default.tls_starttls;
      SMTP_USERNAME = config.programs.msmtp.accounts.default.user;
      SMTP_TIMEOUT = 10;
    };
    environmentFile = config.age.secrets.vaultwarden-env.path;
  };

  services.nginx.virtualHosts."bitwarden.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addNoIndexLocationConf {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden.HTTP}";
        extraConfig = LT.nginx.locationProxyConf;
      };
      "/notifications/hub" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden.Websocket}";
        proxyWebsockets = true;
        extraConfig = LT.nginx.locationProxyConf;
      };
      "/notifications/hub/negotiate" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden.HTTP}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
