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
  imports = [
    ./pict-rs.nix
    ./postgresql.nix
  ];

  services.lemmy = {
    enable = true;
    database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
    ui.port = LT.port.Lemmy.UI;

    settings = {
      hostname = "lemmy.lantian.pub";
      port = LT.port.Lemmy.API;
    };
  };

  services.postgresql = {
    ensureDatabases = ["lemmy"];
    ensureUsers = [
      {
        name = "lemmy";
        ensureDBOwnership = true;
      }
    ];
  };

  lantian.nginxVhosts."lemmy.lantian.pub" = {
    locations = let
      ui = "http://127.0.0.1:${toString cfg.ui.port}";
      backend = "http://127.0.0.1:${toString cfg.settings.port}";
    in {
      "~ ^/(api|pictrs|feeds|nodeinfo|.well-known)" = {
        # backend requests
        proxyPass = backend;
        proxyWebsockets = true;
        extraConfig = LT.nginx.locationProxyConf;
      };
      "/".extraConfig = ''
        set $proxpass "${ui}";
        if ($http_accept = "application/activity+json") {
          set $proxpass "${backend}";
        }
        if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
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

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
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

  systemd.services.lemmy-ui.serviceConfig =
    LT.serviceHarden
    // {
      Restart = "always";
      RestartSec = "3";
      DynamicUser = lib.mkForce false;
      MemoryDenyWriteExecute = false;
      User = "lemmy";
      Group = "lemmy";
    };

  users.users.lemmy = {
    group = "lemmy";
    isSystemUser = true;
  };
  users.groups.lemmy = {};
}
