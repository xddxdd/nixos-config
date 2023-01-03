{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  netns = LT.netns {
    name = "wg-lantian";
    setupDefaultRoute = false;
  };

  flexgetAutoDownloadPath = "/mnt/storage/.downloads-auto";
  radarrMediaPath = "/mnt/storage/media-radarr";
  radarrDownloadPath = "/mnt/storage/downloads-radarr";
  sonarrMediaPath = "/mnt/storage/media-sonarr";
  sonarrDownloadPath = "/mnt/storage/downloads-sonarr";
in
{
  imports = [
    ../../nixos/client-components/xorg.nix

    ../../nixos/optional-apps/flexget.nix
    ../../nixos/optional-apps/jellyfin.nix
    ../../nixos/optional-apps/sonarr.nix
    ../../nixos/optional-apps/transmission-daemon.nix
  ];

  services.xserver.enable = lib.mkForce false;

  systemd.services.jellyfin = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/storage 755 root root"
    "d ${flexgetAutoDownloadPath} ${config.services.transmission.downloadDirPermissions} ${config.services.transmission.user} ${config.services.transmission.group}"
    "d ${radarrDownloadPath} 755 ${config.services.radarr.user} ${config.services.radarr.group}"
    "d ${radarrMediaPath} 755 ${config.services.radarr.user} ${config.services.radarr.group}"
    "d ${sonarrDownloadPath} 755 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d ${sonarrMediaPath} 755 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d /var/lib/nas-tools 755 lantian users"
  ];

  ########################################
  # NAS-Tools
  ########################################

  virtualisation.oci-containers.containers = {
    nas-tools = {
      extraOptions = [ "--pull" "always" ];
      image = "jxxghp/nas-tools";
      ports = [
        "${LT.this.ltnet.IPv4}:3000:3000"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        NASTOOL_AUTO_UPDATE = "false";
      };
      volumes = [
        "/var/lib/nas-tools:/config"
        "/mnt/storage:/mnt/storage"
      ];
    };
  };

  ########################################
  # Sonarr
  ########################################

  systemd.services.flaresolverr = netns.bind { };

  systemd.services.prowlarr = netns.bind { };

  systemd.services.radarr = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = LT.serviceHarden // {
      BindPaths = [ radarrMediaPath radarrDownloadPath ];
    };
  };

  systemd.services.sonarr = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = LT.serviceHarden // {
      BindPaths = [ sonarrMediaPath sonarrDownloadPath ];
    };
  };

  systemd.services.qbittorrent = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      BindPaths = [
        radarrDownloadPath
        radarrMediaPath
        sonarrMediaPath
        sonarrDownloadPath
      ];
    };
  };

  ########################################
  # Transmission
  ########################################

  services.transmission.settings = {
    download-dir = "/mnt/storage/downloads";

    # Limit parallel downloads to avoid system lockup
    download-queue-enabled = lib.mkForce true;
    download-queue-size = 5;
    queue-stalled-enabled = lib.mkForce true;
    queue-stalled-minutes = 10;

    # Speed limit of private trackets
    speed-limit-down = 25600;
    speed-limit-down-enabled = false;
    speed-limit-up = 25600;
    speed-limit-up-enabled = true;
  };

  systemd.services.transmission = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig.BindPaths = [
      flexgetAutoDownloadPath
      radarrDownloadPath
      sonarrDownloadPath
    ];
  };
}
