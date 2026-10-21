{
  LT,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./mysql.nix ];

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
      ROCKET_PORT = LT.port.Vaultwarden;

      DATABASE_URL = "mysql:///vaultwarden";

      USE_SENDMAIL = "true";
      SENDMAIL_COMMAND = lib.getExe pkgs.msmtp;
      SMTP_FROM = config.programs.msmtp.accounts.default.from;
      SMTP_FROM_NAME = "Vaultwarden";
    };
  };

  lantian.nginxVhosts."bitwarden.xuyh0120.win" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden}";
      proxyWebsockets = true;
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
  };

  sops.secrets.smtp-pass.restartUnits = [ "vaultwarden.service" ];

  systemd.services.vaultwarden = {
    path = [ pkgs.msmtp ];
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
    serviceConfig = LT.serviceHarden // {
      RestartSec = "5s";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
      # chroot's tmpfs root is ephemeral; bind data dir and the mysqld unix
      # socket through
      BindPaths = [
        "/var/lib/vaultwarden"
        "/run/mysqld"
      ];
      BindReadOnlyPaths = [
        "${config.environment.etc.msmtprc.source}:/etc/msmtprc"
        config.sops.secrets.smtp-pass.path
      ];
    };
  };
  lantian.harden.vaultwarden = true;
}
