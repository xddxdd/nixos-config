{ inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/grafana.nix
    ../../nixos/optional-apps/nginx-lab
    ../../nixos/optional-apps/prometheus
    ../../nixos/optional-apps/vaultwarden.nix
    ../../nixos/optional-apps/yourls.nix

    "${inputs.secrets}/nixos-hidden-module/7dfa681e7463f997"
  ];

  systemd.network.networks.eth0 = {
    address = [
      "194.32.107.228/24"
      "2a03:94e0:ffff:194:32:107::228/118"
      "2a03:94e0:27ca::1/48"
    ];
    gateway = [
      "194.32.107.1"
      "2a03:94e0:ffff:194:32:107::1"
    ];
    matchConfig.Name = "eth0";
  };
}
