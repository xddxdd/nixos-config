{ pkgs, config, ... }:

{
  services.keycloak = {
    enable = true;
    bindAddress = "127.0.0.1";
    database.passwordFile = "/srv/conf/keycloak/password";
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
