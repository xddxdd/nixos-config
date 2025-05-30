{
  LT,
  config,
  inputs,
  pkgs,
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
      ROCKET_PORT = LT.port.Vaultwarden;

      DATABASE_URL = "mysql:///vaultwarden";

      USE_SENDMAIL = "true";
      SENDMAIL_COMMAND = "${pkgs.msmtp}/bin/msmtp";
      SMTP_FROM = config.programs.msmtp.accounts.default.from;
      SMTP_FROM_NAME = "Vaultwarden";
    };
    environmentFile = config.age.secrets.vaultwarden-env.path;
  };

  lantian.nginxVhosts."bitwarden.xuyh0120.win" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.Vaultwarden}";
      proxyWebsockets = true;
    };

    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
  };

  systemd.services.vaultwarden = {
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
    serviceConfig = {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
    };
  };
}
