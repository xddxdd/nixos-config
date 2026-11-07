{
  LT,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ ./mysql.nix ];

  sops.secrets.vaultwarden-push-installation-id.sopsFile = inputs.secrets + "/vaultwarden.yaml";
  sops.secrets.vaultwarden-push-installation-key.sopsFile = inputs.secrets + "/vaultwarden.yaml";
  sops.templates.vaultwarden-env.content = ''
    PUSH_ENABLED=true
    PUSH_INSTALLATION_ID=${config.sops.placeholder.vaultwarden-push-installation-id}
    PUSH_INSTALLATION_KEY=${config.sops.placeholder.vaultwarden-push-installation-key}
  '';

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
    environmentFile = config.sops.templates.vaultwarden-env.path;
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
    requires = [ "mysql.service" ];
    serviceConfig = {
      RestartSec = "5s";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
      # chroot's tmpfs root is ephemeral; bind data dir through.
      BindPaths = [ "/var/lib/vaultwarden" ];
      BindReadOnlyPaths = [ config.sops.secrets.smtp-pass.path ];
    };
  };
  lantian.harden.vaultwarden = {
    enable = true;
    mysql = true;
    etc.msmtprc = true;
  };
}
