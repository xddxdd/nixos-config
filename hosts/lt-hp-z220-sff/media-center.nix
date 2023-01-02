{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  netns = LT.netns {
    name = "wg-lantian";
    setupDefaultRoute = false;
  };

  sonarrMediaPath = "/mnt/storage/media-sonarr";
  sonarrDownloadPath = "/mnt/storage/downloads-sonarr";
in
{
  imports = [
    ../../nixos/client-components/xorg.nix

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
    "d ${sonarrDownloadPath} 755 ${config.services.sonarr.user} ${config.services.sonarr.group}"
    "d ${sonarrMediaPath} 755 ${config.services.sonarr.user} ${config.services.sonarr.group}"
  ];

  ########################################
  # Sonarr
  ########################################

  systemd.services.prowlarr = netns.bind { };

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
      BindPaths = [ sonarrMediaPath sonarrDownloadPath ];
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
  system.activationScripts.transmission-download-auto =
    let
      cfg = config.services.transmission;
    in
    ''
      install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '/mnt/storage/downloads-auto'
    '';
  systemd.services.transmission = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig.BindPaths = [
      "/mnt/storage/downloads-auto"
    ];
  };
}
