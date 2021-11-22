{ pkgs, config, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
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
    httpPort = "13401";
    httpsPort = "13402";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
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
    listen = nginxHelper.listen443;
    locations = nginxHelper.addCommonLocationConf {
      "= /".return = "302 /auth/admin/";
      "/" = {
        proxyPass = "http://127.0.0.1:13401";
        extraConfig = nginxHelper.locationProxyConf;
      };
    };
    extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.noIndex;
  };
}
