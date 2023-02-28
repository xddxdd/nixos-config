{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  identifierWebapp = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "konnect-identifier-webapp";
    version = "1.0.0";
    src = ./identifier-webapp.tar.zst;
    nativeBuildInputs = with pkgs; [zstd];
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  identifierRegistration = {
    clients = [
      {
        id = "gitea";
        secret = {_secret = config.age.secrets.konnect-gitea-secret.path;};
        name = "Gitea";
        application_type = "web";
        trusted = true;
        redirect_uris = ["https://git.lantian.pub/user/oauth2/Konnect/callback"];
        origins = ["https://git.lantian.pub"];
      }
      {
        id = "grafana";
        secret = {_secret = config.age.secrets.konnect-grafana-secret.path;};
        name = "Grafana";
        application_type = "web";
        trusted = true;
        redirect_uris = ["https://dashboard.xuyh0120.win/login/generic_oauth"];
        origins = ["https://dashboard.xuyh0120.win"];
      }
      {
        id = "miniflux";
        secret = {_secret = config.age.secrets.konnect-miniflux-secret.path;};
        name = "Miniflux";
        application_type = "web";
        trusted = true;
        redirect_uris = [
          "https://rss.xuyh0120.win/oauth2/oidc/callback"
          "https://rss.xuyh0120.win/oauth2/oidc/redirect"
        ];
        origins = ["https://rss.xuyh0120.win"];
      }
      {
        id = "nextcloud";
        secret = {_secret = config.age.secrets.konnect-nextcloud-secret.path;};
        name = "Nextcloud";
        application_type = "web";
        trusted = true;
        redirect_uris = ["https://cloud.xuyh0120.win/apps/sociallogin/custom_oidc/konnect"];
        origins = ["https://cloud.xuyh0120.win"];
      }
      {
        id = "oauth-proxy";
        secret = {_secret = config.age.secrets.konnect-oauth-proxy-secret.path;};
        name = "OAuth Proxy";
        application_type = "web";
        trusted = true;
        insecure = true;
        id_token_signed_response_alg = "RS256";
        request_object_signing_alg = "RS256";
        token_endpoint_auth_signing_alg = "RS256";
      }
    ];
  };
in {
  age.secrets.glauth-bindpw.file = inputs.secrets + "/glauth-bindpw.age";
  age.secrets.konnect--privkey.file = inputs.secrets + "/konnect/_privkey.age";
  age.secrets.konnect--encryption.file = inputs.secrets + "/konnect/_encryption.age";
  age.secrets.konnect-gitea-secret.file = inputs.secrets + "/konnect/gitea-secret.age";
  age.secrets.konnect-grafana-secret.file = inputs.secrets + "/konnect/grafana-secret.age";
  age.secrets.konnect-miniflux-secret.file = inputs.secrets + "/konnect/miniflux-secret.age";
  age.secrets.konnect-nextcloud-secret.file = inputs.secrets + "/konnect/nextcloud-secret.age";
  age.secrets.konnect-oauth-proxy-secret.file = inputs.secrets + "/konnect/oauth-proxy-secret.age";

  systemd.services.konnect = {
    wantedBy = ["multi-user.target"];
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
      };
    environment = {
      LDAP_URI = "ldap://${LT.this.ltnet.IPv4}:${LT.portStr.LDAP}";
      LDAP_BINDDN = "cn=serviceuser,dc=lantian,dc=pub";
      LDAP_BASEDN = "dc=lantian,dc=pub";
      LDAP_SCOPE = "sub";
      LDAP_LOGIN_ATTRIBUTE = "uid";
      LDAP_EMAIL_ATTRIBUTE = "mail";
      LDAP_NAME_ATTRIBUTE = "cn";
      LDAP_UUID_ATTRIBUTE = "uidNumber";
      LDAP_UUID_ATTRIBUTE_TYPE = "text";
      LDAP_FILTER = "(&(objectClass=posixAccount)(!(ou=svcaccts)))";
    };
    script = ''
      export LDAP_BINDPW=$(cat ${config.age.secrets.glauth-bindpw.path})

      ${utils.genJqSecretsReplacementSnippet
        identifierRegistration
        "/run/konnect-identifier-registration.yaml"}

      exec ${pkgs.konnect}/bin/konnectd serve \
        --listen=127.0.0.1:${LT.portStr.Konnect} \
        --iss=https://login.xuyh0120.win \
        --identifier-client-path=${identifierWebapp} \
        --identifier-registration-conf=/run/konnect-identifier-registration.yaml \
        --signing-private-key=${config.age.secrets.konnect--privkey.path} \
        --encryption-secret=${config.age.secrets.konnect--encryption.path} \
        ldap
    '';
  };

  services.nginx.virtualHosts."login.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Konnect}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
