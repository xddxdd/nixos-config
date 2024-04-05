{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  netns = config.lantian.netns.wg-lantian;

  transmissionDownloadPath = "/mnt/storage/downloads";
  transmissionSonarrDownloadPath = "/mnt/storage/.downloads-tr";
  qBitTorrentSonarrDownloadPath = "/mnt/storage/.downloads-qb";
  flexgetAutoDownloadPath = "/mnt/storage/.downloads-auto";
  radarrMediaPath = "/mnt/storage/media-radarr";
  sonarrMediaPath = "/mnt/storage/media-sonarr";
in
{
  imports = [
    ../../nixos/client-components/hidpi.nix
    ../../nixos/client-components/xorg.nix

    ../../nixos/optional-apps/jellyfin.nix
    ../../nixos/optional-apps/sonarr
    ../../nixos/optional-apps/transmission-daemon.nix

    ../../nixos/optional-cron-jobs/flexget
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

  systemd.services.flexget-runner = netns.bind { };

  systemd.services.flaresolverr-netns = netns.bind {
    description = "FlareSolverr (in NetNS)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    path = with pkgs; [ xorg.xorgserver ];
    environment = {
      HOME = "/run/flaresolverr-netns";
      HOST = "127.0.0.1";
      PORT = LT.portStr.FlareSolverr;
      LOG_LEVEL = "warn";
      TZ = config.time.timeZone;
      LANG = config.i18n.defaultLocale;
      TEST_URL = "https://www.example.com";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.flaresolverr}/bin/flaresolverr";
      RuntimeDirectory = "flaresolverr-netns";
      WorkingDirectory = "/run/flaresolverr-netns";

      MemoryDenyWriteExecute = false;
      SystemCallFilter = lib.mkForce [ ];
    };
  };

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

  systemd.services.bazarr = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    path = with pkgs; [ mediainfo ];
    serviceConfig = LT.serviceHarden // {
      BindPaths = [
        radarrMediaPath
        sonarrMediaPath
      ];
    };
  };

  systemd.services.decluttarr = netns.bind { };

  systemd.services.qbittorrent = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      BindPaths = [ qBitTorrentSonarrDownloadPath ];
    };
  };

  lantian.nginxVhosts = {
    "sonarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Sonarr}";
    "sonarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Sonarr}";
    "radarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Radarr}";
    "radarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Radarr}";
    "prowlarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Prowlarr}";
    "prowlarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Prowlarr}";
    "bazarr.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Bazarr}";
    "bazarr.localhost".locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Bazarr}";
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
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig.BindPaths = [
      transmissionDownloadPath
      transmissionSonarrDownloadPath
      flexgetAutoDownloadPath
    ];
  };
}
