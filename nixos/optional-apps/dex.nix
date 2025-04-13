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
        type = "ldap";
        name = "LDAP";
        id = "ldap";
        config = {
          host = "[fdbc:f9dc:67ad:2547::389]:${LT.portStr.LDAPS}";
          insecureNoSSL = false;
          insecureSkipVerify = true;

          bindDN = "cn=serviceuser,dc=lantian,dc=pub";
          bindPW = {
            _secret = config.age.secrets.glauth-bindpw.path;
          };

          usernamePrompt = "Username";

          userSearch = {
            baseDN = "dc=lantian,dc=pub";
            filter = "(objectClass=posixAccount)";
            username = "uid";
            idAttr = "uid";
            emailAttr = "mail";
            nameAttr = "displayName";
            preferredUsernameAttr = "uid";
          };
          groupSearch = {
            baseDN = "dc=lantian,dc=pub";
            filter = "(objectClass=posixGroup)";
            userMatchers = [
              {
                userAttr = "uid";
                groupAttr = "memberUid";
              }
            ];
            nameAttr = "uid";
          };
        };
      }
    ];
    twoFactorAuthn = {
      issuer = "dex";
      connectors = [ "ldap" ];
    };
    staticClients = [
      {
        id = "gitea";
        name = "Gitea";
        secret = {
          _secret = config.age.secrets.dex-gitea-secret.path;
        };
        redirectURIs = [ "https://git.lantian.pub/user/oauth2/Dex/callback" ];
      }
      {
        id = "grafana";
        name = "Grafana";
        secret = {
          _secret = config.age.secrets.dex-grafana-secret.path;
        };
        redirectURIs = [ "https://dashboard.xuyh0120.win/login/generic_oauth" ];
      }
      {
        id = "immich";
        name = "Immich";
        secret = {
          _secret = config.age.secrets.dex-immich-secret.path;
        };
        redirectURIs = [
          "https://immich.xuyh0120.win/auth/login"
          "https://immich.xuyh0120.win/user-settings"
          "https://immich.xuyh0120.win/api/oauth/mobile-redirect"
          "app.immich:///oauth-callback"
        ];
      }
      {
        id = "open-webui";
        name = "Open WebUI";
        secret = {
          _secret = config.age.secrets.dex-open-webui-secret.path;
        };
        redirectURIs = [ "https://ai.xuyh0120.win/oauth/oidc/callback" ];
      }
      {
        id = "oauth-proxy";
        name = "OAuth2 Proxy";
        secret = {
          _secret = config.age.secrets.dex-oauth2-proxy-secret.path;
        };
        redirectURIs = [
          "https://*.lantian.pub/oauth2/callback"
          "https://*.*.lantian.pub/oauth2/callback"
          "https://*.xuyh0120.win/oauth2/callback"
          "https://*.*.xuyh0120.win/oauth2/callback"
        ];
      }
    ];
  };
in
{
  imports = [ ./postgresql.nix ];

  age.secrets =
    {
      glauth-bindpw = {
        file = inputs.secrets + "/glauth-bindpw.age";
        mode = "0444";
      };
    }
    // builtins.listToAttrs (
      builtins.map
        (
          f:
          lib.nameValuePair "dex-${f}-secret" {
            file = inputs.secrets + "/dex/${f}-secret.age";
            owner = "dex";
            group = "dex";
          }
        )
        [
          "gitea"
          "grafana"
          "immich"
          "oauth2-proxy"
          "open-webui"
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
      exec ${pkgs.dex-oidc}/bin/dex serve /run/dex/config.yaml
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

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
