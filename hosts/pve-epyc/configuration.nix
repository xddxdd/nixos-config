{
  config,
  lib,
  ...
}:
{
  imports = [
    ../../nixos/client-components/tlp.nix
    ../../nixos/pve.nix

    ./hardware-configuration.nix
    ./openvswitch.nix
    ./vfio.nix
  ];

  # ECC RAM
  hardware.rasdaemon.enable = true;

  boot.kernelParams = [
    "console=ttyS0,115200"
    "default_hugepagesz=1G"
    "hugepagesz=1G"
    "hugepages=224"
    "amd_pstate=active"
    "amd_pstate.shared_mem=1"
  ];

  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=1073741824
  '';

  services.beesd.filesystems.nvme = {
    spec = config.fileSystems."/mnt/nvme".device;
    hashTableSizeMB = 1024;
    verbosity = "crit";
    extraOptions = [
      "--loadavg-target"
      "4"
      "--workaround-btrfs-send"
    ];
  };

  services.tlp.settings = lib.mapAttrs (_n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "pcowersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
  };

  services.proxmox-ve.bridges = [ "br0" ];
  services.proxmox-ve.ipAddress = "192.168.0.2";

  networking.hosts = {
    "192.168.0.2" = [ config.networking.hostName ];
  };

  systemd.network.networks.br0 = {
    address = [ "192.168.0.2/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "br0";
    linkConfig.MTUBytes = "9000";
  };

  zramSwap.enable = lib.mkForce false;
}
