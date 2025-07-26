{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.tnl-buyvm;

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

    ../../nixos/optional-apps/bitmagnet.nix
    ../../nixos/optional-apps/jellyfin.nix
    ../../nixos/optional-apps/peerbanhelper.nix
    ../../nixos/optional-apps/qbittorrent.nix
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

  systemd.services.bitmagnet-http = netns.bind { };
  systemd.services.bitmagnet-queue = netns.bind { };
  systemd.services.bitmagnet-dht = netns.bind { };
  systemd.services.peerbanhelper = netns.bind { };

  systemd.services.radarr = {
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

  systemd.services.sonarr = {
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

  systemd.services.bazarr = {
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

  systemd.services.qbittorrent = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      BindPaths = [
        transmissionDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };

  systemd.services.vuetorrent-backend.environment.QBIT_BASE =
    lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";

  lantian.nginxVhosts = {
    "qbittorrent.${config.networking.hostName}.xuyh0120.win".locations."/api".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";
    "qbittorrent.localhost".locations."/api".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";
    "bitmagnet.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.Bitmagnet}";
    "bitmagnet.localhost".locations."/".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.Bitmagnet}";
    "peerbanhelper.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.PeerBanHelper}";
    "peerbanhelper.localhost".locations."/".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.PeerBanHelper}";
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
