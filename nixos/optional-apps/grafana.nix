{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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
      };
      "auth.anonymous" = {
        enabled = "true";
      };
      "auth.generic_oauth" = {
        enabled = "true";
        name = "Konnect";
        allow_sign_up = "true";
        scopes = "openid profile email";
        auth_url = "https://login.xuyh0120.win/signin/v1/identifier/_/authorize";
        token_url = "https://login.xuyh0120.win/konnect/v1/token";
        api_url = "https://login.xuyh0120.win/konnect/v1/userinfo";

        # Kopano Konnect doesn't support groups, allow everyone authenticated as admin
        role_attribute_path = "'Admin'";
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
      paths = {
        provisioning = lib.mkForce "";
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
        proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
        extraConfig = LT.nginx.locationProxyConf;
      };
      "/api/live/" = {
        proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
        proxyWebsockets = true;
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
