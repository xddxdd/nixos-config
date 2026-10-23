{
  pkgs,
  inputs,
  lib,
  LT,
  config,
  ...
}:
let
  inherit (pkgs) bitmagnet;

  mkBitmagnetService = worker: {
    description = "BitMagnet ${worker}";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "postgresql.service"
    ];
    wants = [
      "network.target"
      "postgresql.service"
    ];
    environment = {
      POSTGRES_HOST = "/run/postgresql";
      POSTGRES_NAME = "bitmagnet";
      POSTGRES_USER = "bitmagnet";
      TMDB_ENABLED = "true";
      PROCESSOR_CONCURRENCY = builtins.toString LT.this.cpuThreads;
    };
    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe bitmagnet} worker run --keys=${worker}";
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      EnvironmentFile = config.sops.templates.bitmagnet-env.path;
      RuntimeDirectory = "bitmagnet";
      StateDirectory = "bitmagnet";
      WorkingDirectory = "/var/lib/bitmagnet";

      User = "bitmagnet";
      Group = "bitmagnet";
      BindReadOnlyPaths = [ "/run/postgresql" ];
    };
  };
in
{
  imports = [ ./postgresql.nix ];

  sops.secrets.tmdb-api-key = {
    sopsFile = inputs.secrets + "/tmdb.yaml";
    owner = "bitmagnet";
    group = "bitmagnet";
  };

  sops.templates.bitmagnet-env.content = ''
    TMDB_API_KEY=${config.sops.placeholder.tmdb-api-key}
  '';

  systemd.services.bitmagnet-http = mkBitmagnetService "http_server";
  systemd.services.bitmagnet-queue = mkBitmagnetService "queue_server";
  systemd.services.bitmagnet-dht = mkBitmagnetService "dht_crawler";

  services.postgresql = {
    ensureDatabases = [ "bitmagnet" ];
    ensureUsers = [
      {
        name = "bitmagnet";
        ensureDBOwnership = true;
      }
    ];
  };

  lantian.localVhosts.bitmagnet = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Bitmagnet}";
      };
    };
  };

  lantian.harden = {
    bitmagnet-http = true;
    bitmagnet-queue = true;
    bitmagnet-dht = true;
  };

  users.users.bitmagnet = {
    group = "bitmagnet";
    isSystemUser = true;
  };
  users.groups.bitmagnet = { };
}
