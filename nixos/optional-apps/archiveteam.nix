{ LT, ... }:
{
  virtualisation.oci-containers.containers.archiveteam = {
    environment = {
      DOWNLOADER = "lantian";
      SELECTED_PROJECT = "auto";
    };
    labels."io.containers.autoupdate" = "registry";
    image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
    ports = [ "127.0.0.1:${LT.portStr.ArchiveTeam}:8001" ];
    volumes = [ "/var/lib/archiveteam:/home/warrior/projects" ];
  };

  systemd.tmpfiles.settings = {
    archiveteam = {
      "/var/lib/archiveteam"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
    };
  };

  lantian.localVhosts.archiveteam = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.ArchiveTeam}";
        enableOAuth = true;
      };
    };
    accessibleBy = "public";
  };
}
