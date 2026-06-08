{
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  sops.secrets.attic-credentials = {
    sopsFile = inputs.secrets + "/common/attic.yaml";
    owner = "atticd";
    group = "atticd";
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.secrets.attic-credentials.path;
    mode = "monolithic";
    settings = lib.mkForce {
      listen = "[::1]:${LT.portStr.Attic}";
      database = {
        url = "postgres://atticd?host=/run/postgresql&user=atticd";
        heartbeat = true;
      };
      require-proof-of-possession = false;
      storage = {
        type = "s3";
        region = "enam";
        bucket = "lantian-nix-cache";
        endpoint = "https://2d8c04d248c430fff57494a2b722ff49.r2.cloudflarestorage.com";
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
        default-retention-period = "3 month";
      };
    };
  };

  systemd.services.atticd.serviceConfig = LT.serviceHarden // {
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce "";
  };

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
    "attic.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Attic}";
          proxyNoTimeout = true;
        };
      };

      sslCertificate = "zerossl-xuyh0120.win";
      noIndex.enable = true;
    };
    "attic.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://[::1]:${LT.portStr.Attic}";
          proxyNoTimeout = true;
        };
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
