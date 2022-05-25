{ pkgs, lib, config, utils, ... }:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  identifierWebapp = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "konnect-identifier-webapp";
    version = "1.0.0";
    src = ./identifier-webapp.tar.zst;
    nativeBuildInputs = with pkgs; [ zstd ];
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  identifierRegistration = {
    clients = [
      ({
        id = "gitea";
        secret = { _secret = config.age.secrets.konnect-gitea-secret.path; };
        name = "Gitea";
        application_type = "web";
        trusted = true;
        redirect_uris = [ "https://git.lantian.pub/user/oauth2/Konnect/callback" ];
        origins = [ "https://git.lantian.pub" ];
      })
      ({
        id = "grafana";
        secret = { _secret = config.age.secrets.konnect-grafana-secret.path; };
        name = "Grafana";
        application_type = "web";
        trusted = true;
        redirect_uris = [ "https://dashboard.lantian.pub/login/generic_oauth" ];
        origins = [ "https://dashboard.lantian.pub" ];
      })
      ({
        id = "nextcloud";
        secret = { _secret = config.age.secrets.konnect-nextcloud-secret.path; };
        name = "Nextcloud";
        application_type = "web";
        trusted = true;
        redirect_uris = [ "https://cloud.lantian.pub/apps/sociallogin/custom_oidc/konnect" ];
        origins = [ "https://cloud.lantian.pub" ];
      })
      ({
        id = "oauth-proxy";
        secret = { _secret = config.age.secrets.konnect-oauth-proxy-secret.path; };
        name = "OAuth Proxy";
        application_type = "web";
        trusted = true;
        insecure = true;
        id_token_signed_response_alg = "RS256";
        request_object_signing_alg = "RS256";
        token_endpoint_auth_signing_alg = "RS256";
      })
    ];
  };
in
{
  age.secrets.glauth-bindpw.file = pkgs.secrets + "/glauth-bindpw.age";
  age.secrets.konnect-gitea-secret.file = pkgs.secrets + "/konnect/gitea-secret.age";
  age.secrets.konnect-grafana-secret.file = pkgs.secrets + "/konnect/grafana-secret.age";
  age.secrets.konnect-nextcloud-secret.file = pkgs.secrets + "/konnect/nextcloud-secret.age";
  age.secrets.konnect-oauth-proxy-secret.file = pkgs.secrets + "/konnect/oauth-proxy-secret.age";

  systemd.services.konnect = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
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
        --iss=https://login.lantian.pub \
        --identifier-client-path=${identifierWebapp} \
        --identifier-registration-conf=/run/konnect-identifier-registration.yaml \
        ldap
    '';
  };

  services.nginx.virtualHosts."login.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { noindex = true; } {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Konnect}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
