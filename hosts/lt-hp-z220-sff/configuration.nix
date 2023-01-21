{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/none.nix

    ./hardware-configuration.nix
    ./media-center.nix
    ./shares.nix

    ../../nixos/client-components/tlp.nix

    ../../nixos/server-components/backup.nix
    ../../nixos/server-components/logging.nix

    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/sftp-server.nix
  ];

  boot.initrd.systemd.enable = lib.mkForce false;
  boot.kernelParams = [ "pci=realloc,assign-busses" ];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  # Handle multiple NICs
  networking.usePredictableInterfaceNames = lib.mkForce true;

  systemd.network.networks.eno1 = {
    networkConfig = {
      DHCP = "no";
      VLAN = [ "eno1.201" ];
    };
    matchConfig.Name = "eno1";
  };

  systemd.network.netdevs."eno1.201" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "eno1.201";
    };
    vlanConfig = {
      Id = 201;
    };
  };

  systemd.network.networks."eno1.201" = {
    networkConfig.DHCP = "yes";
    matchConfig.Name = "eno1.201";
  };

  systemd.network.networks.ens2f0 = {
    address = [ "192.168.1.2/24" ];
    networkConfig.DHCP = "no";
    networkConfig.DHCPServer = "yes";
    dhcpServerConfig = {
      PoolOffset = 10;
      PoolSize = 200;
      EmitDNS = "yes";
      DNS = config.networking.nameservers;
    };
    matchConfig.Name = "ens2f0";
  };

  systemd.network.networks.ens2f1 = {
    address = [ "192.168.1.3/24" ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens2f1";
  };

  systemd.network.networks.ens2f2 = {
    address = [ "192.168.1.4/24" ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens2f2";
  };

  systemd.network.networks.ens2f3 = {
    address = [ "192.168.1.5/24" ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens2f3";
  };

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 32;
    verbosity = "crit";
    extraOptions = [ "--loadavg-target" "4" ];
  };

  services.beesd.filesystems.storage = {
    spec = config.fileSystems."/mnt/storage".device;
    hashTableSizeMB = 2048;
    verbosity = "crit";
    extraOptions = [ "--loadavg-target" "4" ];
  };

  services.fwupd.enable = true;

  services.tlp.settings = {
    TLP_PERSISTENT_DEFAULT = 1;
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
