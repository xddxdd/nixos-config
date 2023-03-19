{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  netns = config.lantian.netns.wg-lantian;

  transmissionDownloadPath = "/mnt/storage/downloads";
  transmissionSonarrDownloadPath = "/mnt/storage/.downloads-tr";
  qBitTorrentSonarrDownloadPath = "/mnt/storage/.downloads-qb";
  flexgetAutoDownloadPath = "/mnt/storage/.downloads-auto";
  radarrMediaPath = "/mnt/storage/media-radarr";
  sonarrMediaPath = "/mnt/storage/media-sonarr";
in {
  imports = [
    ../../nixos/client-components/xorg.nix

    ../../nixos/optional-apps/flexget.nix
    ../../nixos/optional-apps/sonarr.nix
    ../../nixos/optional-apps/transmission-daemon.nix
  ];

  services.xserver.enable = lib.mkForce false;

  systemd.tmpfiles.rules = [
    "d /mnt/storage 755 root root"
    "d ${flexgetAutoDownloadPath} ${config.services.transmission.downloadDirPermissions} ${config.services.transmission.user} ${config.services.transmission.group}"
    "d ${transmissionSonarrDownloadPath} ${config.services.transmission.downloadDirPermissions} ${config.services.transmission.user} ${config.services.transmission.group}"
    "d ${qBitTorrentSonarrDownloadPath} 755 lantian users"
    "d ${radarrMediaPath} 755 ${config.services.radarr.user} ${config.services.radarr.group}"
    "d ${sonarrMediaPath} 755 ${config.services.sonarr.user} ${config.services.sonarr.group}"
  ];

  ########################################
  # Sonarr
  ########################################

  systemd.services.flaresolverr = netns.bind {};

  systemd.services.prowlarr = netns.bind {};

  systemd.services.radarr = netns.bind {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
    serviceConfig =
      LT.serviceHarden
      // {
        BindPaths = [
          radarrMediaPath
          transmissionSonarrDownloadPath
          qBitTorrentSonarrDownloadPath
        ];
      };
  };

  systemd.services.sonarr = netns.bind {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
    serviceConfig =
      LT.serviceHarden
      // {
        BindPaths = [
          sonarrMediaPath
          transmissionSonarrDownloadPath
          qBitTorrentSonarrDownloadPath
        ];
      };
  };

  systemd.services.qbittorrent = netns.bind {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
    serviceConfig = {
      BindPaths = [
        qBitTorrentSonarrDownloadPath
      ];
    };
  };

  services.nginx.virtualHosts = {
    "sonarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Sonarr}";
    "sonarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Sonarr}";
    "radarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Radarr}";
    "radarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Radarr}";
    "prowlarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Prowlarr}";
    "prowlarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Prowlarr}";
    "qbittorrent.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";
    "qbittorrent.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";
  };

  ########################################
  # Transmission
  ########################################

  services.transmission.settings = {
    download-dir = transmissionDownloadPath;

    # Limit parallel downloads to avoid system lockup
    download-queue-enabled = lib.mkForce true;
    download-queue-size = 20;
    queue-stalled-enabled = lib.mkForce true;
    queue-stalled-minutes = 10;

    # Speed limit of private trackets
    speed-limit-down = 25600;
    speed-limit-down-enabled = false;
    speed-limit-up = 25600;
    speed-limit-up-enabled = true;
  };

  systemd.services.transmission = {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
    serviceConfig.BindPaths = [
      transmissionDownloadPath
      transmissionSonarrDownloadPath
      flexgetAutoDownloadPath
    ];
  };
}
