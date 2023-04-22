{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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
      gvisor
    ]);
  };

  users.users.lantian.extraGroups = ["podman"];

  virtualisation.oci-containers.backend = "podman";
}
