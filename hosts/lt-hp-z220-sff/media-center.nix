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

  ########################################
  # Sonarr
  ########################################

  system.activationScripts.sonarr-download-auto =
    let
      cfg = config.services.sonarr;
    in
    ''
      install -d -m 0775 -o '${cfg.user}' -g '${cfg.group}' '${sonarrDownloadPath}'
      install -d -m 0775 -o '${cfg.user}' -g '${cfg.group}' '${sonarrMediaPath}'
    '';

  systemd.services.jackett = netns.bind { };

  systemd.services.sonarr = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = LT.serviceHarden // {
      AmbientCapabilities = "CAP_DAC_READ_SEARCH";
      CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
      BindPaths = [ sonarrMediaPath sonarrDownloadPath ];
    };
  };

  systemd.services.qbittorrent = netns.bind {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
    serviceConfig = {
      AmbientCapabilities = "CAP_DAC_READ_SEARCH";
      CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
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
