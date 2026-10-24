{
  pkgs,
  lib,
  LT,
  utils,
  config,
  inputs,
  ...
}:
let
  cfg = {
    issuer = "https://login.lantian.pub";
    storage = {
      type = "postgres";
      config.host = "/run/postgresql";
    };
    web.http = "127.0.0.1:${LT.portStr.Dex}";
    oauth2 = {
      responseTypes = [
        "code"
        "token"
        "id_token"
      ];
      skipApprovalScreen = true;
      alwaysShowLoginScreen = false;
    };
    connectors = [
      {
        type = "oidc";
        name = "Pocket ID";
        id = "ldap"; # Backwards compatibility
        config = {
          issuer = "https://id.lantian.pub";
          scopes = [
            "email"
            "profile"
            "groups"
            "offline_access"
          ];
          clientID = {
            _secret = config.sops.secrets.dex-pocket-id-client-id.path;
          };
          clientSecret = {
            _secret = config.sops.secrets.dex-pocket-id-client-secret.path;
          };
          redirectURI = "https://login.lantian.pub/callback";
          insecureSkipEmailVerified = true;
          insecureEnableGroups = true;
          getUserInfo = true;
        };
      }
    ];
    staticClients = [
      # keep-sorted start block=yes
      {
        id = "actual";
        name = "Actual Budget";
        secret = {
          _secret = config.sops.secrets.dex-actual-secret.path;
        };
        redirectURIs = [ "https://actual.xuyh0120.win/openid/callback" ];
      }
      {
        id = "gitea";
        name = "Gitea";
        secret = {
          _secret = config.sops.secrets.dex-gitea-secret.path;
        };
        redirectURIs = [ "https://git.lantian.pub/user/oauth2/Dex/callback" ];
      }
      {
        id = "grafana";
        name = "Grafana";
        secret = {
          _secret = config.sops.secrets.dex-grafana-secret.path;
        };
        redirectURIs = [ "https://dashboard.xuyh0120.win/login/generic_oauth" ];
      }
      {
        id = "hydra";
        name = "Hydra";
        secret = {
          _secret = config.sops.secrets.dex-hydra-secret.path;
        };
        redirectURIs = [ "https://hydra.lantian.pub/oidc-callback/dex" ];
      }
      {
        id = "immich";
        name = "Immich";
        secret = {
          _secret = config.sops.secrets.dex-immich-secret.path;
        };
        redirectURIs = [
          "https://immich.xuyh0120.win/auth/login"
          "https://immich.xuyh0120.win/user-settings"
          "https://immich.xuyh0120.win/api/oauth/mobile-redirect"
          "app.immich:///oauth-callback"
        ];
      }
      {
        id = "nextcloud";
        name = "nextcloud";
        secret = {
          _secret = config.sops.secrets.dex-nextcloud-secret.path;
        };
        redirectURIs = [ "https://cloud.xuyh0120.win/apps/oidc_login/oidc" ];
      }
      {
        id = "oauth-proxy";
        name = "OAuth2 Proxy";
        secret = {
          _secret = config.sops.secrets.dex-oauth-proxy-secret.path;
        };
        redirectURIs = [
          "https://*.lantian.pub/oauth2/callback"
          "https://*.*.lantian.pub/oauth2/callback"
          "https://*.xuyh0120.win/oauth2/callback"
          "https://*.*.xuyh0120.win/oauth2/callback"
        ];
      }
      {
        id = "oidc-tester";
        name = "OIDC Tester";
        secret = {
          _secret = config.sops.secrets.dex-oidc-tester-secret.path;
        };
        redirectURIs = [ "https://oidc-tester.lantian.pub/oauth2/callback" ];
      }
      {
        id = "tranquil-pds";
        name = "Tranquil PDS";
        secret = {
          _secret = config.sops.secrets.dex-tranquil-pds-secret.path;
        };
        redirectURIs = [ "https://at.lantian.pub/oauth/sso/callback" ];
      }
      # keep-sorted end
    ];
  };

  jqSecrets = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg "/run/dex/config.yaml";
in
{
  imports = [ ./postgresql.nix ];

  sops.secrets = {
    dex-pocket-id-client-id = {
      sopsFile = inputs.secrets + "/dex/pocket-id.yaml";
      owner = "dex";
      group = "dex";
    };
    dex-pocket-id-client-secret = {
      sopsFile = inputs.secrets + "/dex/pocket-id.yaml";
      owner = "dex";
      group = "dex";
    };
  }
  // builtins.listToAttrs (
    builtins.map (
      f: lib.nameValuePair "dex-${f.id}-secret" { sopsFile = inputs.secrets + "/dex/${f.id}.yaml"; }
    ) cfg.staticClients
  );

  services.postgresql = {
    ensureDatabases = [ "dex" ];
    ensureUsers = [
      {
        name = "dex";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.dex = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "networking.target"
      "postgresql.target"
    ];
    requires = [ "postgresql.target" ];
    script = ''
      ${jqSecrets.script}
      exec ${lib.getExe pkgs.dex-oidc} serve /run/dex/config.yaml
    '';
    serviceConfig = LT.serviceHarden // {
      LoadCredential = jqSecrets.credentials;
      DynamicUser = lib.mkForce false;
      User = "dex";
      Group = "dex";
      RuntimeDirectory = "dex";
      Restart = "always";
      RestartSec = "5";
      # Postgres unix socket; RuntimeDirectory config.yaml is mounted from the
      # host automatically
      BindReadOnlyPaths = [
        "/run/postgresql"
      ];
    };
  };

  lantian.harden.dex = true;

  users.users.dex = {
    group = "dex";
    isSystemUser = true;
  };
  users.groups.dex.members = [ "nginx" ];

  lantian.nginxVhosts."login.lantian.pub" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.Dex}";
    };

    accessibleBy = "private";
    sslCertificate = "lets-encrypt-lantian.pub";
    noIndex.enable = true;
  };
}
