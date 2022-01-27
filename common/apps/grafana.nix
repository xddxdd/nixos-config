{ pkgs, config, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };
in
{
  imports = [ ./mysql.nix ];

  age.secrets.grafana-dbpw = {
    file = ../../secrets/grafana-dbpw.age;
    owner = "grafana";
    group = "grafana";
  };
  age.secrets.grafana-oauth = {
    file = ../../secrets/grafana-oauth.age;
    owner = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;
    protocol = "socket";
    domain = "dashboard.lantian.pub";
    rootUrl = "https://dashboard.lantian.pub/";
    auth.anonymous.enable = true;

    database = {
      type = "mysql";
      host = "/run/mysqld/mysqld.sock";
      user = "grafana";
      passwordFile = config.age.secrets.grafana-dbpw.path;
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-clock-panel
      grafana-piechart-panel
      grafana-polystat-panel
      grafana-worldmap-panel

      (grafanaPlugin {
        pname = "yesoreyeram-infinity-datasource";
        version = "0.8.0";
        zipHash = "sha256-JDacbdgNoT1vczD7pj0tVKwR3SRmRg1AXdZ5Ak6tzfk=";
      })
    ];

    smtp = with config.programs.msmtp.accounts.default; {
      enable = true;
      host = host;
      user = user;
      passwordFile = config.age.secrets.smtp-pass.path;
      fromAddress = from;
    };

    extraOptions = {
      AUTH_GENERIC_OAUTH_ENABLED = "true";
      AUTH_GENERIC_OAUTH_NAME = "Keycloak";
      AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "true";
      AUTH_GENERIC_OAUTH_SCOPES = "microprofile-jwt";
      AUTH_GENERIC_OAUTH_AUTH_URL = "https://login.lantian.pub/auth/realms/master/protocol/openid-connect/auth";
      AUTH_GENERIC_OAUTH_TOKEN_URL = "https://login.lantian.pub/auth/realms/master/protocol/openid-connect/token";
      AUTH_GENERIC_OAUTH_API_URL = "https://login.lantian.pub/auth/realms/master/protocol/openid-connect/userinfo";
      AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH = "contains(groups[*], 'admin') && 'Admin' || 'Viewer'";

      UNIFIED_ALERTING_ENABLED = "true";
      LOG_MODE = "syslog";
      LOG_LEVEL = "error";
    };
  };

  systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.grafana-oauth.path;
  users.users.nginx.extraGroups = [ "grafana" ];

  services.mysql = {
    ensureDatabases = [ "grafana" ];
    ensureUsers = [
      {
        name = "grafana";
        ensurePermissions = {
          "grafana.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts."dashboard.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {
      "/" = {
        proxyPass = "http://unix:${config.services.grafana.socket}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
