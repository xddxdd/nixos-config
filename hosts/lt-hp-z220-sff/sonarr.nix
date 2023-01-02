{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  netns = LT.netns {
    name = "wg-lantian";
    setupDefaultRoute = false;
  };

  mediaPath = "/mnt/storage/media-sonarr";
  downloadPath = "/mnt/storage/downloads-sonarr";
in
{
  imports = [
    ../../nixos/optional-apps/qbittorrent.nix
  ];

  system.activationScripts.sonarr-download-auto =
    let
      cfg = config.services.sonarr;
    in
    ''
      install -d -m 0775 -o '${cfg.user}' -g '${cfg.group}' '${downloadPath}'
      install -d -m 0775 -o '${cfg.user}' -g '${cfg.group}' '${mediaPath}'
    '';

  services.jackett = {
    enable = true;
    user = "lantian";
    group = "users";
  };
  systemd.services.jackett = lib.recursiveUpdate netns.bindExisting {
    serviceConfig = LT.serviceHarden // {
      StateDirectory = "jackett";
      MemoryDenyWriteExecute = false;
      ProcSubset = "all";
    };
  };

  services.sonarr = {
    enable = true;
    user = "lantian";
    group = "users";
  };
  systemd.services.sonarr = lib.recursiveUpdate netns.bindExisting {
    serviceConfig = LT.serviceHarden // {
      AmbientCapabilities = "CAP_DAC_READ_SEARCH";
      CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      BindPaths = [ mediaPath downloadPath ];
      StateDirectory = "sonarr";
      MemoryDenyWriteExecute = false;
    };
  };

  systemd.services.qbittorrent = lib.recursiveUpdate netns.bindExisting {
    serviceConfig = {
      AmbientCapabilities = "CAP_DAC_READ_SEARCH";
      CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
      BindPaths = [ mediaPath downloadPath ];
    };
  };
}
