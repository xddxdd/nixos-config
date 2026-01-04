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

  age.secrets.pocket-id-encryption-key = {
    file = inputs.secrets + "/pocket-id-encryption-key.age";
    owner = "pocket-id";
    group = "pocket-id";
  };

  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://id.lantian.pub";
      TRUST_PROXY = true;
      DB_PROVIDER = "postgres";
      DB_CONNECTION_STRING = "postgres://pocket-id?host=/run/postgresql&user=pocket-id";
      FILE_BACKEND = "database";
      KEYS_STORAGE = "database";
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

      LDAP_ENABLED = true;
      LDAP_URL = "ldap://[fdbc:f9dc:67ad:2547::389]:${LT.portStr.LDAP}";
      LDAP_BIND_DN = "cn=serviceuser,dc=lantian,dc=pub";
      LDAP_BASE = "dc=lantian,dc=pub";
      LDAP_USER_SEARCH_FILTER = "(&(objectClass=posixAccount)(!(ou=svcaccts)))";
      LDAP_USER_GROUP_SEARCH_FILTER = "(objectClass=posixGroup)";
      LDAP_SOFT_DELETE_USERS = true;
      LDAP_ADMIN_GROUP_NAME = "admin";
      LDAP_ATTRIBUTE_USER_UNIQUE_IDENTIFIER = "uid";
      LDAP_ATTRIBUTE_USER_USERNAME = "uid";
      LDAP_ATTRIBUTE_USER_EMAIL = "mail";
      LDAP_ATTRIBUTE_USER_FIRST_NAME = "givenName";
      LDAP_ATTRIBUTE_USER_LAST_NAME = "sn";
      LDAP_ATTRIBUTE_GROUP_MEMBER = "uniqueMember";
      LDAP_ATTRIBUTE_GROUP_UNIQUE_IDENTIFIER = "cn";
      LDAP_ATTRIBUTE_GROUP_NAME = "cn";
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

  systemd.services.pocket-id.serviceConfig = {
    RuntimeDirectory = "pocket-id";
    RuntimeDirectoryMode = "750";
    ExecStart = lib.mkForce (
      builtins.toString (
        pkgs.writeShellScript "pocket-id-start" ''
          set -euo pipefail
          export ENCRYPTION_KEY=$(cat ${config.age.secrets.pocket-id-encryption-key.path})
          export SMTP_PASSWORD=$(cat ${config.age.secrets.smtp-pass.path})
          export LDAP_BIND_PASSWORD=$(cat ${config.age.secrets.glauth-bindpw.path})
          exec ${lib.getExe pkgs.pocket-id}
        ''
      )
    );
  };
  users.groups.pocket-id.members = [ "nginx" ];

  lantian.nginxVhosts."id.lantian.pub" = {
    locations."/" = {
      proxyPass = "http://unix:/run/pocket-id/pocket-id.sock";
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
