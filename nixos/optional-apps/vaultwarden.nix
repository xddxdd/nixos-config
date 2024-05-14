{
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [ ./mysql.nix ];

  age.secrets.vaultwarden-env.file = inputs.secrets + "/vaultwarden-env.age";

  services.mysql = {
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      {
        name = "vaultwarden";
        ensurePermissions = {
          "vaultwarden.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "mysql";
    config = {
      SIGNUPS_ALLOWED = false;
      DOMAIN = "https://bitwarden.xuyh0120.win";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = LT.port.Vaultwarden.HTTP;
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_PORT = LT.port.Vaultwarden.Websocket;

      DATABASE_URL = "mysql:///vaultwarden";

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

  lantian.nginxVhosts."bitwarden.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden.HTTP}";
      };
      "/notifications/hub" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden.Websocket}";
        proxyWebsockets = true;
      };
      "/notifications/hub/negotiate" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden.HTTP}";
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };

  systemd.services.vaultwarden = {
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
  };
}
