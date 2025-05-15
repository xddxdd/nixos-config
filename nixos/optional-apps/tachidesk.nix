{ LT, config, ... }:
{
  imports = [ ./flaresolverr.nix ];

  virtualisation.oci-containers.containers.tachidesk = {
    extraOptions = [
      "--pull=always"
      "--net=host"
    ];
    image = "ghcr.io/suwayomi/tachidesk:latest";
    environment = {
      TZ = config.time.timeZone;
      BIND_IP = "127.0.0.1";
      BIND_PORT = LT.portStr.Tachidesk;
      WEB_UI_CHANNEL = "bundled";
      AUTO_DOWNLOAD_CHAPTERS = "true";
      AUTO_DOWNLOAD_EXCLUDE_UNREAD = "false";
      AUTO_DOWNLOAD_NEW_CHAPTERS_LIMIT = "0";
      AUTO_DOWNLOAD_IGNORE_REUPLOADS = "false";
      MAX_SOURCES_IN_PARALLEL = "20";
      UPDATE_EXCLUDE_UNREAD = "false";
      UPDATE_EXCLUDE_STARTED = "false";
      UPDATE_EXCLUDE_COMPLETED = "false";
      UPDATE_INTERVAL = "6";
      UPDATE_MANGA_INFO = "true";
      EXTENSION_REPOS = builtins.toJSON [
        "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
      ];
      FLARESOLVERR_ENABLED = "true";
      FLARESOLVERR_URL = "http://127.0.0.1:${LT.portStr.FlareSolverr}";
    };
    volumes = [ "/var/lib/tachidesk:/home/suwayomi/.local/share/Tachidesk" ];
  };

  systemd.tmpfiles.rules = [
    # Tachidesk container uses pid/gid 1000/1000
    "d /var/lib/tachidesk 755 1000 1000"
  ];

  lantian.nginxVhosts."tachidesk.xuyh0120.win" = {
    locations = {
      "/" = {
        enableBasicAuth = true;
        proxyPass = "http://127.0.0.1:${LT.portStr.Tachidesk}";
        proxyWebsockets = true;
      };
    };

    sslCertificate = "xuyh0120.win";
    noIndex.enable = true;
  };
}
