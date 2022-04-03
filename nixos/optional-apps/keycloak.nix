{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.keycloak-dbpw = {
    file = pkgs.secrets + "/keycloak-dbpw.age";
    owner = "keycloak";
    group = "keycloak";
  };

  services.keycloak = {
    enable = true;
    bindAddress = "127.0.0.1";
    database.createLocally = false;
    database.passwordFile = config.age.secrets.keycloak-dbpw.path;
    frontendUrl = "https://login.lantian.pub/auth";
    httpPort = LT.portStr.Keycloak.HTTP;
    httpsPort = LT.portStr.Keycloak.HTTPS;
    themes.lantian = pkgs.keycloak-lantian;

    extraConfig = {
      "subsystem=datasources" = {
        "data-source=KeycloakDS" = {
          check-valid-connection-sql = "select 1";
          background-validation = "true";
          background-validation-millis = "5000";
        };
      };
    };
  };

  systemd.services.keycloak.serviceConfig = LT.serviceHarden // {
    AmbientCapabilities = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    DynamicUser = lib.mkForce false;
    MemoryDenyWriteExecute = false;
  };

  users.users.keycloak = {
    useDefaultShell = true;
    group = "keycloak";
    isSystemUser = true;
  };
  users.groups.keycloak = { };

  services.postgresql = {
    ensureDatabases = [ "keycloak" ];
    ensureUsers = [
      {
        name = "keycloak";
        ensurePermissions = {
          "DATABASE keycloak" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.nginx.virtualHosts."login.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addNoIndexLocationConf {
      "= /".return = "302 /auth/admin/";
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Keycloak.HTTP}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
