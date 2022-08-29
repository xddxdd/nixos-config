{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [ ./mysql.nix ];

  age.secrets.grafana-oauth = {
    file = pkgs.secrets + "/grafana-oauth.age";
    owner = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;
    protocol = "socket";
    domain = "dashboard.xuyh0120.win";
    rootUrl = "https://dashboard.xuyh0120.win/";
    auth.anonymous.enable = true;

    database = {
      type = "mysql";
      host = "/run/mysqld/mysqld.sock";
      user = "grafana";
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-clock-panel
      grafana-piechart-panel
      grafana-polystat-panel
      grafana-worldmap-panel

      (grafanaPlugin {
        pname = "yesoreyeram-infinity-datasource";
        version = "0.8.8";
        zipHash = "sha256-SiG3fimQjJ+qLq59So6zaGanpf8gg8sjsFSMfABf62o=";
      })
    ];

    smtp = with config.programs.msmtp.accounts.default; {
      enable = true;
      inherit host user;
      passwordFile = config.age.secrets.smtp-pass.path;
      fromAddress = from;
    };

    extraOptions = {
      AUTH_OAUTH_AUTO_LOGIN = "true";
      AUTH_GENERIC_OAUTH_ENABLED = "true";
      AUTH_GENERIC_OAUTH_NAME = "Konnect";
      AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "true";
      AUTH_GENERIC_OAUTH_SCOPES = "openid profile email";
      AUTH_GENERIC_OAUTH_AUTH_URL = "https://login.xuyh0120.win/signin/v1/identifier/_/authorize";
      AUTH_GENERIC_OAUTH_TOKEN_URL = "https://login.xuyh0120.win/konnect/v1/token";
      AUTH_GENERIC_OAUTH_API_URL = "https://login.xuyh0120.win/konnect/v1/userinfo";
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
    ensureUsers = [{
      name = "grafana";
      ensurePermissions = {
        "grafana.*" = "ALL PRIVILEGES";
      };
    }];
  };

  services.nginx.virtualHosts."dashboard.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://unix:${config.services.grafana.socket}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
