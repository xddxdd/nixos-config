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
        id = "librechat";
        name = "Librechat";
        secret = {
          _secret = config.sops.secrets.dex-librechat-secret.path;
        };
        redirectURIs = [ "https://ai.xuyh0120.win/oauth/openid/callback" ];
      }
      {
        id = "oauth-proxy";
        name = "OAuth2 Proxy";
        secret = {
          _secret = config.sops.secrets.dex-oauth2-proxy-secret.path;
        };
        redirectURIs = [
          "https://*.lantian.pub/oauth2/callback"
          "https://*.*.lantian.pub/oauth2/callback"
          "https://*.xuyh0120.win/oauth2/callback"
          "https://*.*.xuyh0120.win/oauth2/callback"
        ];
      }
      {
        id = "open-webui";
        name = "Open WebUI";
        secret = {
          _secret = config.sops.secrets.dex-open-webui-secret.path;
        };
        redirectURIs = [ "https://ai.xuyh0120.win/oauth/oidc/callback" ];
      }
      # keep-sorted end
    ];
  };
in
{
  imports = [ ./postgresql.nix ];

  sops.secrets = {
    glauth-bindpw = {
      sopsFile = inputs.secrets + "/common/glauth.yaml";
      mode = "0444";
    };
    dex-pocket-id-client-id = {
      sopsFile = inputs.secrets + "/dex.yaml";
      owner = "dex";
      group = "dex";
    };
    dex-pocket-id-client-secret = {
      sopsFile = inputs.secrets + "/dex.yaml";
      owner = "dex";
      group = "dex";
    };
  }
  // builtins.listToAttrs (
    builtins.map
      (
        f:
        lib.nameValuePair "dex-${f}-secret" {
          sopsFile = inputs.secrets + "/dex.yaml";
          owner = "dex";
          group = "dex";
        }
      )
      [
        # keep-sorted start
        "gitea"
        "grafana"
        "immich"
        "librechat"
        "netbox"
        "oauth2-proxy"
        "open-webui"
        # keep-sorted end
      ]
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
      "postgresql.service"
    ];
    script = ''
      ${utils.genJqSecretsReplacementSnippet cfg "/run/dex/config.yaml"}
      exec ${lib.getExe pkgs.dex-oidc} serve /run/dex/config.yaml
    '';
    serviceConfig = LT.serviceHarden // {
      DynamicUser = lib.mkForce false;
      User = "dex";
      Group = "dex";
      RuntimeDirectory = "dex";
      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.dex = {
    group = "dex";
    isSystemUser = true;
  };
  users.groups.dex.members = [ "nginx" ];

  lantian.nginxVhosts."login.lantian.pub" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.Dex}";
    };

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
