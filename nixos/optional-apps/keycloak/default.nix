{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [ ../postgresql.nix ];

  age.secrets.keycloak-dbpw = {
    file = inputs.secrets + "/keycloak-dbpw.age";
    owner = "keycloak";
    group = "keycloak";
  };

  services.keycloak = {
    enable = true;
    database = {
      createLocally = false;
      type = "postgresql";
      name = "keycloak";
      username = "keycloak";
      passwordFile = config.age.secrets.keycloak-dbpw.path;
    };
    themes.lantian = pkgs.callPackage ./theme-lantian.nix { inherit (LT) sources; };

    sslCertificate = "/nix/persistent/sync-servers/acme.sh/lantian.pub_ecc/fullchain.cer";
    sslCertificateKey = "/nix/persistent/sync-servers/acme.sh/lantian.pub_ecc/lantian.pub.key";

    settings = {
      hostname = "login.lantian.pub";
      http-enabled = true;
      http-host = "127.0.0.1";
      http-port = LT.port.Keycloak.HTTP;
      http-relative-path = "/";
      https-port = LT.port.Keycloak.HTTPS;
      hostname-backchannel-dynamic = false;
      proxy-headers = "xforwarded";
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

  lantian.nginxVhosts."login.lantian.pub" = {
    locations = {
      "= /".return = "307 /admin/";
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Keycloak.HTTP}";
      };
    };

    sslCertificate = "lantian.pub";
    noIndex.enable = true;
  };
}
