{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  imports = [ ./mysql.nix ];

  age.secrets.grafana-oauth = {
    file = inputs.secrets + "/grafana-oauth.age";
    owner = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;

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

    settings = {
      auth = {
        oauth_auto_login = "true";
        oauth_allow_insecure_email_lookup = "true";
      };
      "auth.anonymous" = {
        enabled = "true";
      };
      "auth.generic_oauth" = {
        enabled = "true";
        name = "Keycloak";
        allow_sign_up = "true";
        scopes = "openid profile email microprofile-jwt";
        auth_url = "https://login.lantian.pub/realms/master/protocol/openid-connect/auth";
        token_url = "https://login.lantian.pub/realms/master/protocol/openid-connect/token";
        api_url = "https://login.lantian.pub/realms/master/protocol/openid-connect/userinfo";
        role_attribute_path = "contains(groups[*], 'admin') && 'Admin' || 'Viewer'";
      };
      database = {
        type = "mysql";
        host = "/run/mysqld/mysqld.sock";
        user = "grafana";
      };
      log = {
        mode = "syslog";
        level = "error";
      };
      server = {
        protocol = "socket";
        domain = "dashboard.xuyh0120.win";
        root_url = "https://dashboard.xuyh0120.win/";
        socket = "/run/grafana/grafana.sock";
        socket_mode = "0777";
      };
      smtp = with config.programs.msmtp.accounts.default; {
        enabled = true;
        inherit host user;
        password = "$__file{${config.age.secrets.smtp-pass.path}}";
        from_address = from;
      };
      unified_alerting = {
        enabled = "true";
      };
    };
  };

  systemd.services.grafana.serviceConfig = {
    EnvironmentFile = config.age.secrets.grafana-oauth.path;
    Restart = "on-failure";
    SystemCallFilter = [ "@chown" ];
  };

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

  lantian.nginxVhosts."dashboard.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      };
      "/api/live/" = {
        proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
        proxyWebsockets = true;
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
