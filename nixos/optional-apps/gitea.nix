{ pkgs, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  age.secrets.gitea-dbpw = {
    file = pkgs.secrets + "/gitea-dbpw.age";
    owner = config.services.gitea.user;
    group = "gitea";
  };

  services.gitea = {
    enable = true;
    enableUnixSocket = true;
    appName = "Lan Tian @ Git";
    cookieSecure = true;
    database = {
      type = "mysql";
      socket = "/run/mysqld/mysqld.sock";
      user = "gitea";
      passwordFile = config.age.secrets.gitea-dbpw.path;
      createDatabase = false;
    };
    disableRegistration = true;
    domain = "git.lantian.pub";
    lfs.enable = true;
    log.level = "Warn";
    mailerPasswordFile = config.age.secrets.smtp-pass.path;
    rootUrl = "https://git.lantian.pub/";
    ssh.clonePort = 2222;
    ssh.enable = true;
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
      server = {
        LANDING_PAGE = "explore";
        SSH_DOMAIN = "git.lantian.pub";
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
      mailer = {
        ENABLED = true;
        FROM = "postmaster@lantian.pub";
        HOST = "smtp.sendgrid.net:465";
        IS_TLS_ENABLED = true;
        USER = "apikey";
      };
    };
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
    locations = LT.nginx.addCommonLocationConf {
      "/" = {
        proxyPass = "http://unix:/run/gitea/gitea.sock";
        extraConfig = LT.nginx.locationProxyConf;
      };
      "= /user/login".return = "302 /user/oauth2/Keycloak";
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true;
  };
}
