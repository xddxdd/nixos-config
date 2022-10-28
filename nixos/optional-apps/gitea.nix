{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [ ./mysql.nix ];

  services.gitea = {
    enable = true;
    enableUnixSocket = true;
    appName = "Lan Tian @ Git";
    database = {
      type = "mysql";
      socket = "/run/mysqld/mysqld.sock";
      user = "git";
      name = "gitea";
      createDatabase = false;
    };
    domain = "git.lantian.pub";
    lfs.enable = true;
    mailerPasswordFile = config.age.secrets.smtp-pass.path;
    rootUrl = "https://git.lantian.pub/";
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
      log.level = "Warn";
      server = {
        LANDING_PAGE = "explore";
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
        HOST = "smtp.sendgrid.net:465";
        IS_TLS_ENABLED = true;
        USER = "apikey";
      };
    };
  };

  services.mysql = {
    ensureDatabases = [ "gitea" ];
    ensureUsers = [{
      name = "git";
      ensurePermissions = {
        "gitea.*" = "ALL PRIVILEGES";
      };
    }];
  };

  users.users.git = {
    description = "Gitea Service";
    home = config.services.gitea.stateDir;
    useDefaultShell = true;
    group = "gitea";
    isSystemUser = true;
  };

  users.groups.gitea = { };

  services.nginx.virtualHosts."git.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://unix:/run/gitea/gitea.sock";
        extraConfig = LT.nginx.locationProxyConf;
      };
      "/backup/" = {
        proxyPass = "http://unix:/run/gitea/gitea.sock";
        extraConfig = ''
          body_filter_by_lua_block {
            -- https://stackoverflow.com/a/201378
            ngx.arg[1] = ngx.re.gsub(ngx.arg[1], [[(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])]], "[EMAIL HIDDEN]", "ijo");
          }
        '';
      };
      "= /user/login".return = "302 /user/oauth2/Konnect";
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true;
  };
}
