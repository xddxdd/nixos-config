{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  enabled = config.virtualisation.oci-containers.containers != {} || builtins.elem LT.tags.client LT.this.tags;
in
  lib.mkIf enabled {
    environment.systemPackages = config.virtualisation.podman.extraPackages;

    virtualisation.podman = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = ["-af"];
      };
      # Podman DNS conflicts with my authoritative resolver
      defaultNetwork.settings.dns_enabled = false;
      dockerCompat = true;
      dockerSocket.enable = true;

      extraPackages = lib.optionals pkgs.stdenv.isx86_64 (with pkgs; [
        # FIXME: re-enable when gvisor is fixed
        # gvisor
      ]);
    };

    systemd.services.podman-auto-update.enable = true;
    systemd.timers.podman-auto-update.enable = true;

    users.users.lantian.extraGroups = ["podman"];

    virtualisation.oci-containers.backend = "podman";
  }
