{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ../mysql.nix ];

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
    user = "git";
    mailerPasswordFile = config.sops.secrets.smtp-pass.path;

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
        DISABLE_STARS = true;
        DEFAULT_BRANCH = "master";
      };
      service = {
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
        DEFAULT_ENABLE_TIMETRACKING = true;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
        DISABLE_REGISTRATION = true;
        ENABLE_CAPTCHA = false;
        ENABLE_NOTIFY_MAIL = true;
        ENABLE_BASIC_AUTHENTICATION = false;
        ENABLE_PASSWORD_SIGNIN_FORM = false;
        ENABLE_PASSKEY_AUTHENTICATION = false;
        NO_REPLY_ADDRESS = "hidden.lantian.pub";
        REGISTER_EMAIL_CONFIRM = false;
        REQUIRE_SIGNIN_VIEW = false;
        SHOW_REGISTRATION_BUTTON = false;
      };
      session = {
        PROVIDER = "db";
        COOKIE_SECURE = true;
      };
      mailer = {
        ENABLED = true;
        FROM = config.programs.msmtp.accounts.default.from;
        PROTOCOL = "smtp+starttls";
        SMTP_ADDR = config.programs.msmtp.accounts.default.host;
        SMTP_PORT = config.programs.msmtp.accounts.default.port;
        USER = config.programs.msmtp.accounts.default.user;
      };
      "git.timeout" = {
        DEFAULT = 3600;
        MIGRATE = 3600;
        MIRROR = 3600;
        CLONE = 3600;
        PULL = 3600;
        GC = 3600;
      };
      storage = {
        STORAGE_TYPE = "local";
      };
      actions = {
        ARTIFACT_RETENTION_DAYS = 90;
        RUN_RETENTION_DAYS = 90;
        ZOMBIE_TASK_TIMEOUT = "24h";
        ENDLESS_TASK_TIMEOUT = "24h";
        ABANDONED_JOB_TIMEOUT = "24h";
      };
    };
  };

  systemd.services.gitea.serviceConfig = {
    RuntimeDirectoryMode = lib.mkForce "0755";
    RestartSec = "5s";
    StateDirectory = "gitea";
    BindReadOnlyPaths = [
      "${lib.getExe' pkgs.coreutils "env"}:/usr/bin/env" # for hooks
    ];
  };
  lantian.harden.gitea = {
    enable = true;
    secret = true;
  };

  services.mysql = {
    ensureDatabases = [ "gitea" ];
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

  services.openssh.extraConfig = ''
    Match User git
      AuthorizedKeysFile %h/.ssh/authorized_keys /etc/ssh/authorized_keys.d/%u
  '';

  users.groups.gitea = { };

  lantian.nginxVhosts."git.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/gitea/gitea.sock";
        proxyNoTimeout = true;
      };
      "= /robots.txt".alias = ./robots.txt;
      "= /user/login".return = "307 /user/oauth2/Dex";
    };

    blockDotfiles = false;
    sslCertificate = "lets-encrypt-lantian.pub";
  };
}
