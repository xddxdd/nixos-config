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
    database.createLocally = false;
    database.passwordFile = config.age.secrets.keycloak-dbpw.path;
    themes.lantian = pkgs.lantianCustomized.keycloak-lantian;

    # sslCertificate = "/nix/persistent/sync-servers/acme.sh/lantian.pub_ecc/fullchain.cer";
    # sslCertificateKey = "/nix/persistent/sync-servers/acme.sh/lantian.pub_ecc/lantian.pub.key";

    settings = {
      hostname = "login.xuyh0120.win";
      http-enabled = true;
      http-host = "127.0.0.1";
      http-port = LT.port.Keycloak.HTTP;
      http-relative-path = "/auth";
      https-port = LT.port.Keycloak.HTTPS;
      hostname-strict-backchannel = true;
      proxy = "edge";
    };
  };

  systemd.services.keycloak.serviceConfig = LT.serviceHarden // {
    AmbientCapabilities = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    DynamicUser = lib.mkForce false;
    MemoryDenyWriteExecute = false;

    Restart = "always";
    RestartSec = "10s";
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

  services.nginx.virtualHosts."login.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { noindex = true; } {
      "= /".return = "302 /auth/admin/";
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Keycloak.HTTP}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
