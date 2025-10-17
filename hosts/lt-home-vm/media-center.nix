{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.tnl-buyvm;

  defaultDownloadPath = "/mnt/storage/downloads";
  qBitTorrentPTSonarrDownloadPath = "/mnt/storage/.downloads-qb-pt";
  qBitTorrentSonarrDownloadPath = "/mnt/storage/.downloads-qb";
  flexgetAutoDownloadPath = "/mnt/ssd-temp/.downloads-auto";
  radarrMediaPath = "/mnt/storage/media-radarr";
  sonarrMediaPath = "/mnt/storage/media-sonarr";
in
{
  imports = [
    ../../nixos/client-components/hidpi.nix
    ../../nixos/client-components/xorg.nix

    # ../../nixos/optional-apps/bitmagnet.nix
    ../../nixos/optional-apps/jellyfin.nix
    ../../nixos/optional-apps/peerbanhelper.nix
    ../../nixos/optional-apps/qbittorrent.nix
    ../../nixos/optional-apps/qbittorrent-pt.nix
    ../../nixos/optional-apps/sonarr

    ../../nixos/optional-cron-jobs/flexget
  ];

  services.xserver.enable = lib.mkForce false;

  systemd.tmpfiles.settings = {
    storage = {
      "/mnt/storage".d = {
        mode = "755";
        user = "root";
        group = "root";
      };
      "${flexgetAutoDownloadPath}".d = {
        mode = "755";
        user = "lantian";
        group = "users";
      };
      "${qBitTorrentPTSonarrDownloadPath}".d = {
        mode = "755";
        user = "lantian";
        group = "users";
      };
      "${qBitTorrentSonarrDownloadPath}".d = {
        mode = "755";
        user = "lantian";
        group = "users";
      };
      "${radarrMediaPath}".d = {
        mode = "755";
        inherit (config.services.radarr) user;
        inherit (config.services.radarr) group;
      };
      "${sonarrMediaPath}".d = {
        mode = "755";
        inherit (config.services.sonarr) user;
        inherit (config.services.sonarr) group;
      };
    };
  };

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
        qBitTorrentPTSonarrDownloadPath
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
        qBitTorrentPTSonarrDownloadPath
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
        defaultDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };

  systemd.services.qbittorrent-pt = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      BindPaths = [
        defaultDownloadPath
        flexgetAutoDownloadPath
        qBitTorrentPTSonarrDownloadPath
      ];
    };
  };

  lantian.nginxVhosts = {
    "qbittorrent.${config.networking.hostName}.xuyh0120.win".locations."/".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";
    "qbittorrent.localhost".locations."/".proxyPass =
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
}
