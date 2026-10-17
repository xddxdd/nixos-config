{
  inputs,
  lib,
  config,
  LT,
  pkgs,
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

  systemd.services.pocket-id.serviceConfig = LT.serviceHarden // {
    RestartSec = lib.mkForce 5;
    RuntimeDirectory = "pocket-id";
    RuntimeDirectoryMode = "750";
    # chroot's tmpfs root is ephemeral; bind state dir + socket through; the
    # socket is accessed by nginx outside the chroot
    BindPaths = [
      "/var/lib/pocket-id"
      "/run/pocket-id"
    ];
    # sops secrets, postgres unix socket, CA certs for SMTP TLS
    BindReadOnlyPaths = [
      "/run/postgresql"
      "/run/secrets/pocket-id-encryption-key"
      "/run/secrets/smtp-pass"
      "/etc/ssl/certs"
      # Peer auth to postgres and the GeoLite DB need the real uid/hosts
      # environment; user namespace would break postgres peer auth
      "${config.environment.etc."geoip".source}:/etc/geoip"
    ];
    PrivateUsers = lib.mkForce false;
    ExecStart = lib.mkForce (
      builtins.toString (
        pkgs.writeShellScript "pocket-id-start" ''
          set -euo pipefail
          export ENCRYPTION_KEY=$(cat ${config.sops.secrets.pocket-id-encryption-key.path})
          export SMTP_PASSWORD=$(cat ${config.sops.secrets.smtp-pass.path})
          exec ${lib.getExe pkgs.pocket-id}
        ''
      )
    );
  };
  systemd.services.pocket-id.confinement = { enable = true; fullUnit = true; };
  users.groups.pocket-id.members = [ "nginx" ];

  lantian.nginxVhosts."id.lantian.pub" = {
    locations."/" = {
      proxyPass = "http://unix:/run/pocket-id/pocket-id.sock";
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-lantian.pub";
    noIndex.enable = true;
  };
}
