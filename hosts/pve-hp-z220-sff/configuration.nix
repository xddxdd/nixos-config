{
  config,
  lib,
  ...
}:
{
  imports = [
    ../../nixos/client-components/tlp.nix
    ../../nixos/pve.nix

    ../../nixos/optional-cron-jobs/smart-check

    ./hardware-configuration.nix
  ];

  # Don't need PVE on this system for now
  services.proxmox-ve.enable = lib.mkForce false;

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
    TLP_DEFAULT_MODE = "AC";
    TLP_PERSISTENT_DEFAULT = 1;
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "pcowersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
  };

  networking.hosts = {
    "192.168.0.3" = [ config.networking.hostName ];
  };

  systemd.network.networks.eno1 = {
    address = [ "192.168.0.3/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "eno1";
    linkConfig.MTUBytes = "9000";
  };
}
