{ pkgs, config, ... }:

{
  age.secrets.vaultwarden-env.file = ../../secrets/vaultwarden-env.age;

  services.vaultwarden = {
    enable = true;
    config = {
      SIGNUPS_ALLOWED = false;
      DOMAIN = "https://bitwarden.lantian.pub";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 13772;
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_PORT = 13773;

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
}
