{
  LT,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  waline = pkgs.nur-xddxdd.waline.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../../patches/waline-fix-avatar.patch
      ../../../patches/waline-force-load-config.patch
    ];

    postFixup = (old.postFixup or "") + ''
      substituteInPlace $out/lib/node_modules/@waline/vercel/src/config/adapter.js \
        --replace-fail "logSql: true" "logSql: false"

      cp -r ${./config}/* $out/lib/node_modules/@waline/vercel/
    '';
  });
in
{
  imports = [ ../postgresql.nix ];

  sops.secrets.telegram-bot-token.sopsFile = inputs.secrets + "/telegram.yaml";
  sops.secrets.telegram-bot-chat-id.sopsFile = inputs.secrets + "/telegram.yaml";
  sops.secrets.waline-openrouter-key.sopsFile = inputs.secrets + "/waline.yaml";
  sops.secrets.waline-jwt-token.sopsFile = inputs.secrets + "/waline.yaml";
  sops.templates.waline-env.content = ''
    SMTP_PASS=${config.sops.placeholder.smtp-pass}
    TELEGRAM_BOT_TOKEN=${config.sops.placeholder.telegram-bot-token}
    TELEGRAM_CHAT_ID=${config.sops.placeholder.telegram-bot-chat-id}
    OPENAI_API_KEY=${config.sops.placeholder.waline-openrouter-key}
    JWT_TOKEN=${config.sops.placeholder.waline-jwt-token}

  '';

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

      sslCertificate = "lets-encrypt-lantian.pub";
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

  systemd.services.waline = {
    description = "Waline comment system";
    after = [
      "network.target"
      "postgresql.target"
    ];
    requires = [ "postgresql.target" ];
    partOf = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      WALINE_RUNTIME_PATH = "/run/waline";
      HOST = LT.this.ltnet.IPv4;
      PORT = LT.portStr.Waline;

      PG_DB = "waline";
      PG_USER = "waline";
      PG_PASSWORD = "";
      PG_PORT = "5432";
      PG_HOST = "/run/postgresql";

      SITE_NAME = "Lan Tian @ Blog";
      SITE_URL = "https://lantian.pub";
      AUTHOR_EMAIL = "lantian@lantian.pub";
      AKISMET_KEY = "false";

      SMTP_HOST = config.programs.msmtp.accounts.default.host;
      SMTP_PORT = builtins.toString config.programs.msmtp.accounts.default.port;
      SMTP_USER = config.programs.msmtp.accounts.default.user;
      SMTP_SECURE = if (!config.programs.msmtp.accounts.default.tls_starttls) then "true" else "false";
      SENDER_EMAIL = config.programs.msmtp.accounts.default.from;
      SENDER_NAME = "Lan Tian @ Blog";
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = lib.getExe waline;
      EnvironmentFile = config.sops.templates.waline-env.path;
      Restart = "always";
      RestartSec = 3;
      User = "waline";
      Group = "waline";

      RuntimeDirectory = "waline";
      WorkingDirectory = "${waline}/lib/node_modules/@waline/vercel";
      BindReadOnlyPaths = [ "/run/postgresql" ];

      MemoryDenyWriteExecute = lib.mkForce false;
      SystemCallFilter = lib.mkForce [ ];
    };
  };
  lantian.harden.waline = true;

  users.users.waline = {
    group = "waline";
    isSystemUser = true;
    uid = 65532;
  };
  users.groups.waline.gid = 65532;
}
