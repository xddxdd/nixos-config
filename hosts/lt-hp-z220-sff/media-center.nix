{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/client-components/xorg.nix

    ../../nixos/optional-apps/jellyfin.nix
    ../../nixos/optional-apps/transmission-daemon.nix
  ];

  services.xserver.enable = lib.mkForce false;

  systemd.services.jellyfin = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
  };

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
