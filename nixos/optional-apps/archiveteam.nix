{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.archiveteam = {
    extraOptions = [ "--pull=always" ];
    environment = {
      DOWNLOADER = "lantian";
      SELECTED_PROJECT = "auto";
    };
    image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
    ports = [ "127.0.0.1:${LT.portStr.ArchiveTeam}:8001" ];
    volumes = [ "/var/lib/archiveteam:/home/warrior/projects" ];
  };

  systemd.tmpfiles.rules = [
    # ArchiveTeam container uses pid/gid 1000/1000
    "d /var/lib/archiveteam 755 1000 1000"
  ];

  lantian.nginxVhosts = {
    "archiveteam.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.ArchiveTeam}";
        };
      };

      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "archiveteam.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.ArchiveTeam}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
