{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [./mysql.nix];

  services.gitea = {
    enable = true;
    appName = "Lan Tian @ Git";
    database = {
      type = "mysql";
      socket = "/run/mysqld/mysqld.sock";
      user = "git";
      name = "gitea";
      createDatabase = false;
    };
    lfs.enable = true;
    mailerPasswordFile = config.age.secrets.smtp-pass.path;
    user = "git";

    settings = {
      ui = {
        DEFAULT_SHOW_FULL_NAME = true;
        SHOW_USER_EMAIL = false;
      };
      "ui.meta" = {
        AUTHOR = "Lan Tian @ Git";
        DESCRIPTION = "Lan Tian's Git service.";
        KEYWORDS = "go,git,self-hosted,gitea";
      };
      log = {
        LEVEL = "Error";
      };
      server = {
        DOMAIN = "git.lantian.pub";
        LANDING_PAGE = "explore";
        PROTOCOL = "http+unix";
        ROOT_URL = "https://git.lantian.pub/";
        SSH_DOMAIN = "git.lantian.pub";
        SSH_PORT = 2222;
      };
      repository = {
        DEFAULT_PRIVATE = "private";
        ENABLE_PUSH_CREATE_ORG = true;
        ENABLE_PUSH_CREATE_USER = true;
        USE_COMPAT_SSH_URI = true;
      };
      service = {
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
        DEFAULT_ENABLE_TIMETRACKING = true;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
        DISABLE_REGISTRATION = true;
        ENABLE_CAPTCHA = false;
        ENABLE_NOTIFY_MAIL = false;
        NO_REPLY_ADDRESS = "hidden.lantian.pub";
        REGISTER_EMAIL_CONFIRM = false;
        REQUIRE_SIGNIN_VIEW = false;
        SHOW_REGISTRATION_BUTTON = false;
      };
      session.COOKIE_SECURE = true;
      mailer = {
        ENABLED = true;
        FROM = "postmaster@lantian.pub";
        SMTP_ADDR = "smtp.sendgrid.net";
        SMTP_PORT = 465;
        PROTOCOL = "smtps";
        USER = "apikey";
      };
      "git.timeout" = {
        DEFAULT = 3600;
        MIGRATE = 3600;
        MIRROR = 3600;
        CLONE = 3600;
        PULL = 3600;
        GC = 3600;
      };
    };
  };

  systemd.services.gitea.serviceConfig = {
    RuntimeDirectoryMode = lib.mkForce "0755";
  };

  services.mysql = {
    ensureDatabases = ["gitea"];
    ensureUsers = [
      {
        name = "git";
        ensurePermissions = {
          "gitea.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  users.users.git = {
    description = "Gitea Service";
    home = config.services.gitea.stateDir;
    useDefaultShell = true;
    group = "gitea";
    isSystemUser = true;
  };

  users.groups.gitea = {};

  lantian.nginxVhosts."git.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/gitea/gitea.sock";
      };
      "/backup/" = {
        proxyPass = "http://unix:/run/gitea/gitea.sock";
        extraConfig = ''
          header_filter_by_lua_block {
            if ngx.header.content_type:find("^text/html") ~= nil then
              ngx.header.content_length = nil
            end
          }
          body_filter_by_lua_block {
            if ngx.header.content_type:find("^text/html") ~= nil then
              -- https://stackoverflow.com/a/201378
              ngx.arg[1] = ngx.re.gsub(ngx.arg[1], [[(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])]], "[EMAIL HIDDEN]", "ijo");
            end
          }
        '';
      };
      "= /user/login".return = "302 /user/oauth2/Keycloak";
    };

    blockDotfiles = false;
    sslCertificate = "lantian.pub_ecc";
  };
}
