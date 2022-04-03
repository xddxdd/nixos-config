{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    crun
  ];

  virtualisation.podman = {
    enable = true;
    # Podman DNS conflicts with my authoritative resolver
    defaultNetwork.dnsname.enable = false;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  users.users.lantian.extraGroups = [ "podman" ];

  virtualisation.oci-containers.backend = "podman";
}
