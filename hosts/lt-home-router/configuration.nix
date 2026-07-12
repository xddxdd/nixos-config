{ ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./ddns.nix
    ./ddns-bunny.nix
    ./dhcp.nix
    ./firewall.nix
    ./hardware-configuration.nix
    ./networking.nix

    ../../nixos/common-apps/coredns.nix
    ../../nixos/client-components/multicast-dns.nix
    ../../nixos/optional-apps/lancache.nix
    ../../nixos/optional-apps/miniupnpd.nix
    ../../nixos/optional-apps/nmea-static-gps-server.nix
    ../../nixos/optional-apps/ncps.nix
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

  services.lancache.environment = {
    LANCACHE_IP = "192.168.0.4";
    DNS_BIND_IP = "192.168.0.4";
    CACHE_ROOT = "/mnt/unreliable-cache/lancache";
  };

  services.ncps.cache = {
    dataPath = "/mnt/unreliable-cache/ncps";
    tempPath = "/mnt/unreliable-cache/ncps-tmp";
  };
}
