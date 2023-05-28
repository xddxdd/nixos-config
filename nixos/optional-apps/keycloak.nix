{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [./postgresql.nix];

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
    # themes.lantian = pkgs.lantianCustomized.keycloak-lantian;

    sslCertificate = "/nix/persistent/sync-servers/acme.sh/lantian.pub_ecc/fullchain.cer";
    sslCertificateKey = "/nix/persistent/sync-servers/acme.sh/lantian.pub_ecc/lantian.pub.key";

    settings = {
      hostname = "login.lantian.pub";
      http-enabled = true;
      http-host = "127.0.0.1";
      http-port = LT.port.Keycloak.HTTP;
      http-relative-path = "/";
      https-port = LT.port.Keycloak.HTTPS;
      hostname-strict-backchannel = true;
      proxy = "edge";
    };
  };

  systemd.services.keycloak.serviceConfig =
    LT.serviceHarden
    // {
      AmbientCapabilities = lib.mkForce ["CAP_NET_BIND_SERVICE"];
      CapabilityBoundingSet = lib.mkForce ["CAP_NET_BIND_SERVICE"];
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
  users.groups.keycloak = {};

  services.nginx.virtualHosts."login.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
      "= /".return = "302 /admin/";
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Keycloak.HTTP}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig =
      LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
