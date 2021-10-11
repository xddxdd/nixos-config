{ pkgs, config, ... }:

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
}
