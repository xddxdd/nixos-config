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
    ../../nixos/common-apps/nginx/vhost-options
    ../../nixos/client-components/multicast-dns.nix
    ../../nixos/optional-apps/lancache.nix
    ../../nixos/optional-apps/miniupnpd.nix
    ../../nixos/optional-apps/nmea-static-gps-server.nix
    ../../nixos/optional-apps/tayga.nix
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
    storage.local = "/mnt/unreliable-cache/ncps";
    tempPath = "/mnt/unreliable-cache/ncps-tmp";
  };

  # Restored cache files can retain the previous system account's numeric UID.
  systemd.tmpfiles.settings.ncps-restored = {
    "/mnt/unreliable-cache/ncps"."Z" = {
      user = "ncps";
      group = "ncps";
    };
    "/mnt/unreliable-cache/ncps-tmp"."Z" = {
      user = "ncps";
      group = "ncps";
    };
  };
}
