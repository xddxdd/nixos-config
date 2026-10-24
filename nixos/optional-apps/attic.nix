{
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  sops.secrets.attic-server-token.sopsFile = inputs.secrets + "/attic.yaml";
  sops.templates.attic-env.content = ''
    ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder.attic-server-token}
  '';

  services.atticd = {
    enable = true;
    environmentFile = config.sops.templates.attic-env.path;
    mode = "monolithic";
    settings = lib.mkForce {
      listen = "[::1]:${LT.portStr.Attic}";
      database = {
        url = "postgres://atticd?host=/run/postgresql&user=atticd";
        heartbeat = true;
      };
      require-proof-of-possession = false;
      storage = {
        type = "local";
        path = "/var/cache/attic";
      };
      # Disable chunking to use S3 direct download
      chunking = {
        nar-size-threshold = 0;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      compression = {
        type = "zstd";
        level = 9;
      };
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "1 month";
      };
    };
  };

  systemd.services.atticd.serviceConfig = LT.serviceHarden // {
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce "";
    CacheDirectory = lib.mkForce "attic";
    BindReadOnlyPaths = [ "/run/postgresql" ];
  };
  lantian.harden.atticd = true;

  users.users.atticd = {
    group = "atticd";
    isSystemUser = true;
  };
  users.groups.atticd = { };

  services.postgresql = {
    ensureDatabases = [ "atticd" ];
    ensureUsers = [
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
  };

  lantian.nginxVhosts = {
    "cache.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Attic}";
          proxyNoTimeout = true;
        };
      };

      sslCertificate = "lets-encrypt-lantian.pub";
      noIndex.enable = true;
    };
  };

  lantian.localVhosts.attic = {
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${LT.portStr.Attic}";
        proxyNoTimeout = true;
      };
    };
  };
}
