{ pkgs, ... }:
{
  imports = [ ../postgresql.nix ];

  services.mautrix-gmessages = {
    enable = true;
    package = pkgs.nur-xddxdd.mautrix-gmessages;
    settings = {
      homeserver.address = "https://matrix.lantian.pub";
      appservice = {
        hostname = "127.0.0.1";
        id = "gmessages";
      };
      database = {
        type = "postgres";
        uri = "postgresql:///mautrix-gmessages?host=/run/postgresql";
      };
      bridge.permissions = {
        "@lantian:lantian.pub" = "admin";
      };
      network.aggressive_reconnect = true;
      backfill.enabled = true;
    };
    doublePuppet = true;
    registerToSynapse = true;
  };

  users.groups.mautrix-gmessages.members = [ "matrix-synapse" ];

  services.postgresql = {
    ensureDatabases = [ "mautrix-gmessages" ];
    ensureUsers = [
      {
        name = "mautrix-gmessages";
        ensureDBOwnership = true;
      }
    ];
  };
}
