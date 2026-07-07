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
      snapshotFrom = "/nix/persistent/var/lib/vz/virtiofs";
      snapshotTo = "/nix/persistent/var/lib/vz/virtiofs/.snapshot-nixos-home-rdp";
      backupPath = "/nix/persistent/var/lib/vz/virtiofs/.snapshot-nixos-home-rdp/virtiofs/nixos-home-rdp/persistent";
    };
    nvme-nixos-home-vm = {
      snapshotFrom = "/nix/persistent/var/lib/vz/virtiofs";
      snapshotTo = "/nix/persistent/var/lib/vz/virtiofs/.snapshot-nixos-home-vm";
      backupPath = "/nix/persistent/var/lib/vz/virtiofs/.snapshot-nixos-home-vm/virtiofs/nixos-home-vm/persistent";
    };
  };

  services.nfs.server = {
    hostName = lib.mkForce "0.0.0.0";
    exports = lib.mkForce ''
      /mnt/storage 192.168.1.10(rw,insecure,no_subtree_check,no_root_squash) 192.168.1.13(rw,insecure,no_subtree_check,no_root_squash)
    '';
  };
  systemd.services.nfs-server = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
  };

  services.proxmox-ve.bridges = [ "br0" ];
  services.proxmox-ve.ipAddress = "192.168.0.2";

  networking.hosts = {
    "192.168.0.2" = [ config.networking.hostName ];
  };

  systemd.network.netdevs."br0.1" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "br0.1";
    };
    vlanConfig.Id = 1;
  };

  systemd.network.networks.br0 = {
    address = [ "192.168.0.2/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "br0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::2";
      DHCPv6Client = "no";
    };
    networkConfig.VLAN = [ "br0.1" ];
  };

  systemd.network.networks."br0.1" = {
    address = [ "192.168.1.2/24" ];
    matchConfig.Name = "br0.1";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "no";
  };
}
