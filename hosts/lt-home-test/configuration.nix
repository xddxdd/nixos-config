{ lib, config, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
    # ./vpp.nix

    ../../nixos/common-apps/nginx

    ../../nixos/client-components/tlp.nix

    ../../nixos/server-components/backup.nix
    ../../nixos/server-components/logging.nix

    ../../nixos/optional-apps/vlmcsd.nix
  ];

  boot.kernelParams = [ "pci=realloc,assign-busses" ];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = [
      "--loadavg-target"
      "4"
    ];
  };

  # Rename to LAN to apply correct firewall rules
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x8086", ATTR{device/device}=="0x100e",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = [ "192.168.1.13/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "lan0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::13";
      DHCPv6Client = "no";
    };
    routes = [
      {
        Destination = "64:ff9b::/96";
        Gateway = "_ipv6ra";
      }
    ];
  };

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (_n: lib.mkForce) {
    TLP_DEFAULT_MODE = "BAT";
    TLP_PERSISTENT_DEFAULT = 1;
  };
}
