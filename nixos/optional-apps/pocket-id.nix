{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  lantian.geoip.enable = true;

  sops.secrets.pocket-id-encryption-key = {
    sopsFile = inputs.secrets + "/pocket-id.yaml";
    owner = "pocket-id";
    group = "pocket-id";
  };
  sops.templates.pocket-id-env.content = ''
    ENCRYPTION_KEY=${config.sops.placeholder.pocket-id-encryption-key}
    SMTP_PASSWORD=${config.sops.placeholder.smtp-pass}
  '';

  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://id.lantian.pub";
      TRUST_PROXY = true;
      DB_CONNECTION_STRING = "postgres://pocket-id?host=/run/postgresql&user=pocket-id";
      FILE_BACKEND = "database";
      GEOLITE_DB_PATH = "/etc/geoip/GeoLite2-City.mmdb";
      UNIX_SOCKET = "/run/pocket-id/pocket-id.sock";
      UNIX_SOCKET_MODE = "0660";
      UI_CONFIG_DISABLED = true;
      ANALYTICS_DISABLED = true;

      APP_NAME = "Lan Tian @ Login";
      EMAILS_VERIFIED = true;
      ALLOW_OWN_ACCOUNT_EDIT = false;
      DISABLE_ANIMATIONS = true;

      SMTP_HOST = config.programs.msmtp.accounts.default.host;
      SMTP_PORT = builtins.toString config.programs.msmtp.accounts.default.port;
      SMTP_FROM = config.programs.msmtp.accounts.default.from;
      SMTP_USER = config.programs.msmtp.accounts.default.user;
      SMTP_TLS = if config.programs.msmtp.accounts.default.tls_starttls then "starttls" else "tls";
      EMAIL_ONE_TIME_ACCESS_AS_ADMIN_ENABLED = true;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "pocket-id" ];
    ensureUsers = [
      {
        name = "pocket-id";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.pocket-id.after = [ "postgresql.target" ];
  systemd.services.pocket-id.requires = [ "postgresql.target" ];
  systemd.services.pocket-id.serviceConfig = {
    RestartSec = lib.mkForce 5;
    EnvironmentFile = [ config.sops.templates.pocket-id-env.path ];
    RuntimeDirectory = "pocket-id";
    RuntimeDirectoryMode = "750";
    PrivateUsers = lib.mkForce false;
    StateDirectory = "pocket-id";
  };
  users.groups.pocket-id.members = [ "nginx" ];
  lantian.harden.pocket-id = {
    enable = true;
    postgresql = true;
    etc.geoip = true;
  };

  lantian.nginxVhosts."id.lantian.pub" = {
    locations."/" = {
      proxyPass = "http://unix:/run/pocket-id/pocket-id.sock";
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-lantian.pub";
    noIndex.enable = true;
  };
}
