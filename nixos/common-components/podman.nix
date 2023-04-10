{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  environment.systemPackages = with pkgs; [
    crun
  ];

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
  };

  users.users.lantian.extraGroups = ["podman"];

  virtualisation.oci-containers.backend = "podman";
}
