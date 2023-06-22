{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  cfg = config.services.lemmy;
in {
  imports = [./postgresql.nix];

  services.lemmy = {
    enable = true;
    database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";

    settings = {
      hostname = "lemmy.lantian.pub";
    };
  };

  services.postgresql = {
    ensureDatabases = ["lemmy"];
    ensureUsers = [
      {
        name = "lemmy";
        ensurePermissions = {
          "DATABASE \"lemmy\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts."lemmy.lantian.pub" = {
    listen = lib.mkForce LT.nginx.listenHTTPS;
    locations = let
      ui = "http://127.0.0.1:${toString cfg.ui.port}";
      backend = "http://127.0.0.1:${toString cfg.settings.port}";
    in {
      "~ ^/(api|pictrs|feeds|nodeinfo|.well-known)" = {
        # backend requests
        proxyPass = backend;
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
      "/".extraConfig = ''
        set $proxpass "${ui}";
        if ($http_accept ~ "^application/.*$") {
          set $proxpass "${backend}";
        }
        if ($request_method = POST) {
          set $proxpass "${backend}";
        }
        proxy_pass $proxpass;

        rewrite ^(.+)/+$ $1 permanent;

        # Send actual client IP upstream
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
    extraConfig =
      LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  systemd.services.lemmy = {
    after = ["postgresql.service"];
    requires = ["postgresql.service"];

    serviceConfig =
      LT.serviceHarden
      // {
        Restart = "always";
        RestartSec = "3";
        DynamicUser = lib.mkForce false;
        User = "lemmy";
        Group = "lemmy";
      };
  };

  systemd.services.pict-rs = {
    serviceConfig =
      LT.serviceHarden
      // {
        Restart = "always";
        RestartSec = "3";
        DynamicUser = lib.mkForce false;
        User = "pict-rs";
        Group = "pict-rs";
        StateDirectory = "/var/lib/pict-rs";
      };
  };

  users.users.lemmy = {
    group = "lemmy";
    isSystemUser = true;
  };
  users.groups.lemmy = {};

  users.users.pict-rs = {
    group = "pict-rs";
    isSystemUser = true;
  };
  users.groups.pict-rs = {};
}
