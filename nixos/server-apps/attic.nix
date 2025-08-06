{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
lib.mkIf (!(LT.this.hasTag LT.tags.low-disk)) {
  age.secrets.attic-credentials = {
    file = inputs.secrets + "/attic-credentials.age";
    owner = "atticd";
    group = "atticd";
  };

  services.atticd = {
    enable = true;
    package = pkgs.nur-xddxdd.lantianCustomized.attic-telnyx-compatible;
    environmentFile = config.age.secrets.attic-credentials.path;
    mode = if config.networking.hostName == "terrahost" then "monolithic" else "api-server";
    settings = lib.mkForce {
      listen = "[::1]:${LT.portStr.Attic}";
      # Database configured with env var
      database = { };
      require-proof-of-possession = false;
      storage = {
        type = "s3";
        region = "us-central-1";
        bucket = "lantian-nix-cache";
        endpoint = "https://us-central-1.telnyxstorage.com";
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
