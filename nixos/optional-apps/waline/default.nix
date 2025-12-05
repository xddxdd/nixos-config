{
  LT,
  config,
  inputs,
  pkgs,
  ...
}:
let
  configPath = ./config;
  startupScript = pkgs.writeScript "waline-startup" ''
    #!/usr/bin/env bash
    set -euo pipefail
    cp ${configPath}/* node_modules/@waline/vercel/
    sed -i "s/logSql: true/logSql: false/g" node_modules/@waline/vercel/src/config/adapter.js
    exec node node_modules/@waline/vercel/vanilla.js
  '';
in
{
  imports = [ ../postgresql.nix ];

  age.secrets.waline-env.file = inputs.secrets + "/waline-env.age";

  lantian.nginxVhosts = {
    "comments.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Waline}";
          extraConfig = ''
            proxy_set_header REMOTE-HOST $remote_addr;
          '';
        };
        "= /".return = "307 /ui/";
      };

      sslCertificate = "zerossl-lantian.pub";
      noIndex.enable = true;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "waline" ];
    ensureUsers = [
      {
        name = "waline";
        ensureDBOwnership = true;
      }
    ];
  };

  virtualisation.oci-containers.containers = {
    waline = {
      extraOptions = [
        "--uidmap=0:65532:1"
        "--gidmap=0:65532:1"
      ];
      image = "docker.io/lizheming/waline";
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.Waline}:8360" ];
      environment = {
        PG_DB = "waline";
        PG_USER = "waline";
        PG_PASSWORD = "";
        PG_PORT = "5432";
        PG_HOST = "/run/postgresql";

        SITE_NAME = "Lan Tian @ Blog";
        SITE_URL = "https://lantian.pub";
        AKISMET_KEY = "false";

        SMTP_HOST = config.programs.msmtp.accounts.default.host;
        SMTP_PORT = builtins.toString config.programs.msmtp.accounts.default.port;
        SMTP_USER = config.programs.msmtp.accounts.default.user;
        SMTP_SECURE = if (!config.programs.msmtp.accounts.default.tls_starttls) then "true" else "false";
        SENDER_EMAIL = config.programs.msmtp.accounts.default.from;
        SENDER_NAME = "Lan Tian @ Blog";
      };
      environmentFiles = [ config.age.secrets.waline-env.path ];
      volumes = [
        "${configPath}:${configPath}:ro"
        "${startupScript}:${startupScript}:ro"
        "/run/postgresql:/run/postgresql"
      ];
      entrypoint = "${startupScript}";
    };
  };

  systemd.services.podman-waline = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  users.users.waline = {
    group = "waline";
    isSystemUser = true;
    uid = 65532;
  };
  users.groups.waline.gid = 65532;
}
