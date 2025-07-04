{
  LT,
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  age.secrets.glauth-bindpw = {
    file = inputs.secrets + "/glauth-bindpw.age";
    mode = "0444";
  };

  services.postgresql = {
    ensureDatabases = [ "quassel" ];
    ensureUsers = [
      {
        name = "quassel";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.quassel = {
    name = "quassel";
    description = "Quassel IRC client daemon";
    group = "quassel";
    uid = config.ids.uids.quassel;
  };

  users.groups.quassel = {
    name = "quassel";
    gid = config.ids.gids.quassel;
  };

  systemd.services.quassel = {
    description = "Quassel IRC client daemon";

    wantedBy = [ "multi-user.target" ];
    after =
      [ "network.target" ]
      ++ lib.optional config.services.postgresql.enable "postgresql.service"
      ++ lib.optional config.services.mysql.enable "mysql.service";

    environment = {
      DB_BACKEND = "PostgreSQL";
      DB_PGSQL_DATABASE = "quassel";
      DB_PGSQL_HOSTNAME = "/run/postgresql";
      DB_PGSQL_USERNAME = "quassel";
      DB_PGSQL_PORT = "5432";

      AUTH_AUTHENTICATOR = "LDAP";
      AUTH_LDAP_BASE_DN = "dc=lantian,dc=pub";
      AUTH_LDAP_BIND_DN = "cn=serviceuser,dc=lantian,dc=pub";
      AUTH_LDAP_FILTER = "(&(objectClass=posixAccount)(!(ou=svcaccts)))";
      AUTH_LDAP_HOSTNAME = "ldap://[fdbc:f9dc:67ad:2547::389]";
      AUTH_LDAP_PORT = LT.portStr.LDAP;
      AUTH_LDAP_UID_ATTRIBUTE = "cn";
    };

    script = ''
      export AUTH_LDAP_BIND_PASSWORD=$(cat ${config.age.secrets.glauth-bindpw.path})
      exec ${pkgs.quasselDaemon}/bin/quasselcore \
        --listen=0.0.0.0,:: \
        --port=${LT.portStr.Quassel.Main} \
        --configdir=/run/quassel \
        --config-from-environment \
        --require-ssl \
        --ssl-cert=${LT.nginx.getSSLCert "lets-encrypt-lantian.pub-ecc"} \
        --ssl-key=${LT.nginx.getSSLKey "lets-encrypt-lantian.pub-ecc"} \
        --ident-daemon \
        --ident-listen=0.0.0.0,:: \
        --ident-port=${LT.portStr.Quassel.Ident}
    '';

    serviceConfig = LT.serviceHarden // {
      User = "quassel";
      Group = "quassel";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

      RuntimeDirectory = "quassel";
      MemoryDenyWriteExecute = false;
      Restart = "always";
      RestartSec = 5;
    };
  };
}
