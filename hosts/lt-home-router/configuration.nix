{ ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./ddns.nix
    ./dhcp.nix
    ./firewall.nix
    ./hardware-configuration.nix
    ./networking.nix

    ../../nixos/common-apps/coredns.nix
    ../../nixos/server-components/sidestore-vpn.nix
    ../../nixos/optional-apps/miniupnpd.nix
    ../../nixos/optional-apps/ncps-client.nix
  ];

  services.miniupnpd = {
    externalInterface = "eth1.201";
    internalIPs = [
      "eth0"
      "eth0.1"
      "eth0.2"
      # "eth0.5" # IoT devices not allowed UPnP
    ];
  };
}
