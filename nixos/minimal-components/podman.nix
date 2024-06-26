{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  options.lantian.enablePodman = lib.mkOption {
    type = lib.types.bool;
    default = config.virtualisation.oci-containers.containers != { } || LT.this.hasTag LT.tags.client;
  };

  config = lib.mkIf config.lantian.enablePodman {
    environment.systemPackages = config.virtualisation.podman.extraPackages;

    virtualisation.podman = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = [ "-af" ];
      };
      # Podman DNS conflicts with my authoritative resolver
      defaultNetwork.settings.dns_enabled = false;
      dockerCompat = true;
      dockerSocket.enable = true;

      extraPackages = lib.optionals pkgs.stdenv.isx86_64 (with pkgs; [ gvisor ]);
    };

    systemd.services.podman-auto-update.enable = true;
    systemd.timers.podman-auto-update.enable = true;

    users.users.lantian.extraGroups = [ "podman" ];

    virtualisation.oci-containers.backend = "podman";
  };
}
