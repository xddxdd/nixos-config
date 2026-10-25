{
  pkgs,
  lib,
  LT,
  config,
  serviceHardenArgs,
  ...
}:
let
  netns = config.lantian.netns.tnl-buyvm;

  defaultDownloadPath = "/mnt/storage/downloads";
  qBitTorrentPTSonarrDownloadPath = "/mnt/storage/.downloads-qb-pt";
  qBitTorrentSonarrDownloadPath = "/mnt/storage/.downloads-qb";
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
    ../../nixos/optional-apps/qbittorrent-pt.nix
    ../../nixos/optional-apps/sonarr
    ../../nixos/optional-cron-jobs/sonarr-queue-cleanup
  ];

  services.xserver.enable = lib.mkForce false;

  systemd.tmpfiles.settings = {
    storage = {
      "/mnt/storage".d = {
        mode = "755";
        user = "root";
        group = "root";
      };
      "${defaultDownloadPath}".d = {
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

  # Recursive ownership fix for restored state trees (systemd StateDirectory
  # only chowns the top directory); runs via tmpfiles on every activation
  systemd.tmpfiles.settings."arr-state-ownership" = {
    "/var/lib/radarr"."Z" = {
      mode = "-";
      user = "lantian";
      group = "users";
    };
  };

  ########################################
  # Sonarr
  ########################################

  systemd.services.bitmagnet-http = netns.bind { };
  systemd.services.bitmagnet-queue = netns.bind { };
  systemd.services.bitmagnet-dht = netns.bind { };
  systemd.services.peerbanhelper = netns.bind { };
  systemd.services.jellyfin.unitConfig.RequiresMountsFor = "/mnt/storage";

  systemd.services.radarr = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      StateDirectory = lib.mkForce "radarr radarr/asp";
      BindPaths = [
        defaultDownloadPath
        radarrMediaPath
        qBitTorrentPTSonarrDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };
  lantian.harden.radarr = {
    enable = true;
    passwd = true;
    etc = {
      "resolv.conf" = true;
      # Preserve stored bt.localhost endpoints only in this application's view.
      hosts = pkgs.concatText "radarr-hosts" [
        config.environment.etc.hosts.source
        (pkgs.writeText "radarr-bt-localhost" "127.0.0.1 bt.localhost\n")
      ];
      "ssl/certs/ca-certificates.crt" = true;
      "ssl/certs/ca-bundle.crt" = config.environment.etc."ssl/certs/ca-certificates.crt".source;
    };
  };

  systemd.services.sonarr = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      BindPaths = [
        defaultDownloadPath
        sonarrMediaPath
        qBitTorrentPTSonarrDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };
  lantian.harden.sonarr = {
    enable = true;
    passwd = true;
    etc = {
      "resolv.conf" = true;
      # Preserve stored bt.localhost endpoints only in this application's view.
      hosts = pkgs.concatText "radarr-hosts" [
        config.environment.etc.hosts.source
        (pkgs.writeText "radarr-bt-localhost" "127.0.0.1 bt.localhost\n")
      ];
      "ssl/certs/ca-certificates.crt" = true;
      "ssl/certs/ca-bundle.crt" = config.environment.etc."ssl/certs/ca-certificates.crt".source;
    };
  };

  systemd.services.bazarr = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    path = with pkgs; [ mediainfo ];
    serviceConfig = {
      BindPaths = [
        radarrMediaPath
        sonarrMediaPath
      ];
    };
  };
  lantian.harden.bazarr.enable = true;

  systemd.services.qbittorrent = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    environment.XDG_CACHE_HOME = "/var/lib/qbittorrent/qBittorrent/cache";
    environment.XDG_CONFIG_HOME = "/var/lib/qbittorrent/qBittorrent/config";
    environment.XDG_DATA_HOME = "/var/lib/qbittorrent/qBittorrent/data";
    serviceConfig = {
      StateDirectory = "qbittorrent";
      BindPaths = [
        defaultDownloadPath
        qBitTorrentSonarrDownloadPath
      ];
    };
  };
  lantian.harden.qbittorrent = {
    enable = true;
    etc = {
      "resolv.conf" = "/etc/netns/tnl-buyvm/resolv.conf";
      hosts = true;
      "ssl/certs/ca-certificates.crt" = true;
      "ssl/certs/ca-bundle.crt" = config.environment.etc."ssl/certs/ca-certificates.crt".source;
    };
  };

  systemd.services.qbittorrent-pt = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    environment.XDG_CACHE_HOME = "/var/lib/qbittorrent-pt/qBittorrent/cache";
    environment.XDG_CONFIG_HOME = "/var/lib/qbittorrent-pt/qBittorrent/config";
    environment.XDG_DATA_HOME = "/var/lib/qbittorrent-pt/qBittorrent/data";
    serviceConfig = {
      # Preserve the two original merged preset sequences verbatim.
      SystemCallFilter = serviceHardenArgs.SystemCallFilter ++ serviceHardenArgs.SystemCallFilter;
      StateDirectory = "qbittorrent-pt";
      BindPaths = [
        defaultDownloadPath
        qBitTorrentPTSonarrDownloadPath
      ];
    };
  };
  lantian.harden.qbittorrent-pt = {
    enable = true;
    etc = {
      "resolv.conf" = true;
      hosts = true;
      "ssl/certs/ca-certificates.crt" = true;
      "ssl/certs/ca-bundle.crt" = config.environment.etc."ssl/certs/ca-certificates.crt".source;
    };
  };

  lantian.localVhosts = {
    bitmagnet.locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.Bitmagnet}";
    bt.locations."/".proxyPass = lib.mkForce "http://${netns.ipv4}:${LT.portStr.qBitTorrent.WebUI}";
    peerbanhelper.locations."/".proxyPass =
      lib.mkForce "http://${netns.ipv4}:${LT.portStr.PeerBanHelper}";
  };
}
