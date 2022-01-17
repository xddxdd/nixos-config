{ pkgs, config, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
in
{
  imports = [ ./postgresql.nix ];

  age.secrets.keycloak-dbpw = {
    file = ../../secrets/keycloak-dbpw.age;
    mode = "0444";
  };

  services.keycloak = {
    enable = true;
    bindAddress = "127.0.0.1";
    database.createLocally = false;
    database.passwordFile = config.age.secrets.keycloak-dbpw.path;
    frontendUrl = "https://login.lantian.pub/auth";
    httpPort = LT.portStr.Keycloak.HTTP;
    httpsPort = LT.portStr.Keycloak.HTTPS;
  };

  systemd.services.keycloak.serviceConfig.DynamicUser = pkgs.lib.mkForce false;
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
    locations = LT.nginx.addCommonLocationConf {
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
