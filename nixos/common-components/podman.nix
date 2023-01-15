{ pkgs, lib, LT, config, utils, inputs, ... }@args:

lib.mkIf (!config.boot.isContainer) {
  environment.systemPackages = with pkgs; [
    crun
  ];

  virtualisation.podman = {
    enable = true;
    # Podman DNS conflicts with my authoritative resolver
    defaultNetwork.settings.dns_enabled = false;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  users.users.lantian.extraGroups = [ "podman" ];

  virtualisation.oci-containers.backend = "podman";
}
