{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  netns = LT.netns {
    name = "wg-lantian";
    setupDefaultRoute = false;
  };

  transmissionDownloadPath = "/mnt/storage/downloads";
  transmissionSonarrDownloadPath = "/mnt/storage/.downloads-tr";
  qBitTorrentSonarrDownloadPath = "/mnt/storage/.downloads-qb";
  flexgetAutoDownloadPath = "/mnt/storage/.downloads-auto";
  radarrMediaPath = "/mnt/storage/media-radarr";
  sonarrMediaPath = "/mnt/storage/media-sonarr";
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
    "d ${transmissionSonarrDownloadPath} ${config.services.transmission.downloadDirPermissions} ${config.services.transmission.user} ${config.services.transmission.group}"
    "d ${qBitTorrentSonarrDownloadPath} 755 lantian users"
    "d ${radarrMediaPath} 755 ${config.services.radarr.user} ${config.services.radarr.group}"
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
      BindPaths = [
        radarrMediaPath
        transmissionSonarrDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };

  systemd.services.sonarr = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = LT.serviceHarden // {
      BindPaths = [
        sonarrMediaPath
        transmissionSonarrDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };

  systemd.services.qbittorrent = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      BindPaths = [
        qBitTorrentSonarrDownloadPath
      ];
    };
  };

  ########################################
  # Transmission
  ########################################

  services.transmission.settings = {
    download-dir = transmissionDownloadPath;

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
      transmissionDownloadPath
      transmissionSonarrDownloadPath
      flexgetAutoDownloadPath
    ];
  };
}
