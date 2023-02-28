{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
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
in {
  imports = [
    ../../nixos/client-components/xorg.nix

    ../../nixos/optional-apps/jellyfin.nix
  ];

  services.xserver.enable = lib.mkForce false;

  systemd.services.jellyfin = {
    after = ["mnt-storage.mount"];
    requires = ["mnt-storage.mount"];
  };
}
