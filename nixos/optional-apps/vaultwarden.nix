{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.vaultwarden-env.file = pkgs.secrets + "/vaultwarden-env.age";

  services.postgresql = {
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      {
        name = "vaultwarden";
        ensurePermissions = {
          "DATABASE \"vaultwarden\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      SIGNUPS_ALLOWED = false;
      DOMAIN = "https://bitwarden.xuyh0120.win";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = LT.port.Vaultwarden.HTTP;
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_PORT = LT.port.Vaultwarden.Websocket;

      DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";

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

  services.nginx.virtualHosts."bitwarden.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
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
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
