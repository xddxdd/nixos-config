{
  LT,
  config,
  lib,
  ...
}:
{
  options.lantian.archivebox = {
    storage = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/archivebox";
      description = "Storage path for ArchiveBox data";
    };
  };

  config = {
    virtualisation.oci-containers.containers.archivebox = {
      environment = {
        REVERSE_PROXY_USER_HEADER = "X-Remote-User";
        REVERSE_PROXY_WHITELIST = "10.88.0.1/32";
      };
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      image = "docker.io/archivebox/archivebox:latest";
      ports = [ "127.0.0.1:${LT.portStr.ArchiveBox}:8000" ];
      volumes = [ "${config.lantian.archivebox.storage}:/data" ];
    };

    systemd.tmpfiles.settings = {
      archivebox = {
        "${config.lantian.archivebox.storage}"."d" = {
          mode = "755";
          user = "911"; # ArchiveBox default user ID
          group = "911"; # ArchiveBox default group ID
        };
      };
    };

    lantian.nginxVhosts = {
      "archivebox.${config.networking.hostName}.xuyh0120.win" = {
        locations = {
          "/" = {
            enableOAuth = true;
            proxyPass = "http://127.0.0.1:${LT.portStr.ArchiveBox}";
          };
        };

        accessibleBy = "private";
        sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
        noIndex.enable = true;
      };
      "archivebox.localhost" = {
        listenHTTP.enable = true;
        listenHTTPS.enable = false;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${LT.portStr.ArchiveBox}";
          };
        };

        noIndex.enable = true;
        accessibleBy = "localhost";
      };
    };
  };
}
