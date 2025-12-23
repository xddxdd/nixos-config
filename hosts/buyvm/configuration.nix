{ inputs, ... }:
{
  imports = [
    ../../nixos/server.nix

    (inputs.secrets + "/dn42/buyvm.nix")

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "107.189.12.254/24"
      "2605:6400:30:f22f::1/48"
      "2605:6400:cac6::1/48"
    ];
    gateway = [
      "107.189.12.1"
      "2605:6400:30::1"
    ];
    matchConfig.Name = "eth0";
  };

  # DN42 legacy address
  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::20:5549:a809/128" ];

  services.route-chain.routes = [
    "2605:6400:30:f22f::1/120"
    "2605:6400:cac6::1/120"
  ];
}
