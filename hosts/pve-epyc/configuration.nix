{
  config,
  lib,
  ...
}:
{
  imports = [
    ../../nixos/pve.nix

    ../../nixos/optional-apps/nfs.nix

    ./enable-smart.nix
    ./hardware-configuration.nix
    ./openvswitch.nix
  ];

  boot.kernelParams = [
    "console=ttyS0,115200"
    "amd_pstate=active"
    "amd_pstate.shared_mem=1"
  ];

  lantian.backup.enable = true;
  lantian.backup.paths = {
    nvme-nixos-home-rdp = {
      snapshotFrom = "/mnt/nvme";
      snapshotTo = "/mnt/nvme/.snapshot-nixos-home-rdp";
      backupPath = "/mnt/nvme/.snapshot-nixos-home-rdp/virtiofs/nixos-home-rdp/persistent";
    };
    nvme-nixos-home-vm = {
      snapshotFrom = "/mnt/nvme";
      snapshotTo = "/mnt/nvme/.snapshot-nixos-home-vm";
      backupPath = "/mnt/nvme/.snapshot-nixos-home-vm/virtiofs/nixos-home-vm/persistent";
    };
  };

  services.nfs.server = {
    hostName = lib.mkForce "192.168.0.2";
    exports = lib.mkForce ''
      /mnt/nvme/virtiofs/nixos-home-vm 192.168.1.10(rw,insecure,no_subtree_check,no_root_squash)
      /mnt/nvme/virtiofs/nixos-home-builder 192.168.1.12(rw,insecure,no_subtree_check,no_root_squash)
      /mnt/nvme/virtiofs/nixos-home-rdp 192.168.1.13(rw,insecure,no_subtree_check,no_root_squash)
      /mnt/storage 192.168.1.10(rw,insecure,no_subtree_check,no_root_squash) 192.168.1.13(rw,insecure,no_subtree_check,no_root_squash)
    '';
  };
  systemd.services.nfs-server = {
    after = [
      "mnt-storage.mount"
      "mnt-nvme.mount"
    ];
    requires = [
      "mnt-storage.mount"
      "mnt-nvme.mount"
    ];
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

  services.beesd.filesystems.nvme = {
    spec = config.fileSystems."/mnt/nvme".device;
    hashTableSizeMB = 1024;
    verbosity = "crit";
    extraOptions = [
      "--loadavg-target"
      "32"
      "--workaround-btrfs-send"
    ];
  };
}
