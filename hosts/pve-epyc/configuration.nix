{
  config,
  lib,
  LT,
  ...
}:
{
  imports = [
    ../../nixos/pve.nix
    ../../nixos/server.nix

    ./enable-smart.nix
    ./hardware-configuration.nix
    ./media-center.nix
    ./openvswitch.nix
    ./shares.nix
    ./smfc

    ../../nixos/client-apps/gnupg.nix
    ../../nixos/client-apps/vscode-remote-env.nix
    ../../nixos/client-components/cups.nix
    ../../nixos/client-components/impermanence.nix
    ../../nixos/optional-apps/archivebox.nix
    ../../nixos/optional-apps/archiveteam.nix
    ../../nixos/optional-apps/asf.nix
    # ../../nixos/optional-apps/calibre-cops.nix # PHP services disabled by request
    ../../nixos/optional-apps/clamav.nix
    # ../../nixos/optional-apps/dlx.nix # missing regenerated secret dlx.yaml
    # ../../nixos/optional-apps/epic-awesome-gamer # missing regenerated secret epic-awesome-gamer.yaml
    ../../nixos/optional-apps/fastapi-dls.nix
    # # ../../nixos/optional-apps/handbrake-server.nix
    ../../nixos/optional-apps/hydra
    ../../nixos/optional-apps/i2pd.nix
    ../../nixos/optional-apps/immich.nix
    # ../../nixos/optional-apps/iyuuplus.nix # missing regenerated secret iyuu.yaml
    ../../nixos/optional-apps/kubo.nix
    ../../nixos/optional-apps/llama-cpp.nix
    # ../../nixos/optional-apps/microsoft-rewards-script.nix # missing regenerated secrets
    ../../nixos/optional-apps/mtranserver
    # # ../../nixos/optional-apps/n8n # compromised
    ../../nixos/optional-apps/ncps-client.nix
    ../../nixos/optional-apps/netns-tnl-buyvm.nix
    ../../nixos/optional-apps/nfs.nix
    ../../nixos/optional-apps/nginx-openspeedtest.nix
    ../../nixos/optional-apps/opencl.nix
    # ../../nixos/optional-apps/resin.nix # missing regenerated secret resin.yaml
    # ../../nixos/optional-apps/searxng.nix # missing regenerated secret searxng.yaml
    ../../nixos/optional-apps/sftp-server.nix
    # # ../../nixos/optional-apps/strata.nix
    ../../nixos/optional-apps/syncthing
    ../../nixos/optional-apps/tachidesk.nix
    ../../nixos/optional-apps/tor.nix
    ../../nixos/optional-apps/vlmcsd.nix
    ../../nixos/optional-apps/webdav.nix

    ../../nixos/optional-cron-jobs/ncmm.nix
    ../../nixos/optional-cron-jobs/qbittorrent-pt-cleanup
    # ../../nixos/optional-cron-jobs/radicale-calendar-sync.nix # missing regenerated secret
    ../../nixos/optional-cron-jobs/rsgain-cloudmusic.nix
  ];

  boot.kernelParams = [
    "console=ttyS0,115200"
    "amd_pstate=active"
    "amd_pstate.shared_mem=1"
  ];

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
    address = [
      "192.168.0.2/24"
      "2001:470:e997::2/64"
    ];
    gateway = [
      "192.168.0.1"
      "2001:470:e997::1"
    ];
    matchConfig.Name = "br0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "no";
    networkConfig.VLAN = [ "br0.1" ];
  };

  systemd.network.networks."br0.1" = {
    address = [ "192.168.1.2/24" ];
    matchConfig.Name = "br0.1";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "no";
  };

  services.printing = {
    browsing = true;
    defaultShared = true;
    # XXX: temporary debug level to diagnose lpadmin/driverd failure
    logLevel = "debug2";
    listenAddresses = [
      "127.0.0.1:631"
      "192.168.0.2:631"
    ];
    allowFrom = [ "all" ];
  };

  lantian.immich.storage = "/mnt/storage/immich";
  # lantian.syncthing.storage = "/mnt/storage/media";
  lantian.archivebox.storage = "/mnt/storage/archivebox";

  systemd.services = {
    backup-nix-persistent.unitConfig.RequiresMountsFor = [
      "/mnt/storage"
      "/run/sftp"
    ];
    backup-prune.unitConfig.RequiresMountsFor = [
      "/mnt/storage"
      "/run/sftp"
    ];
    systemd-tmpfiles-setup.unitConfig.RequiresMountsFor = "/mnt/storage";
    systemd-tmpfiles-resetup.unitConfig.RequiresMountsFor = "/mnt/storage";
  };

  # Allow Radicale calendar sync task to access *arr config
  systemd.services.radicale-calendar-sync.serviceConfig = {
    AmbientCapabilities = [ "CAP_DAC_OVERRIDE" ];
    CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];
  };

  systemd.services.immich-machine-learning.environment = {
    CUDA_DEVICE_ORDER = "PCI_BUS_ID";
    CUDA_VISIBLE_DEVICES = "1";
  };

  services.scx.enable = lib.mkForce true;

  # Avoid nix builds saturating CPU
  systemd.services.nix-daemon.serviceConfig.CPUAffinity = "16-${
    builtins.toString (LT.this.cpuThreads - 1)
  }";
  nix.settings.cores = LT.this.cpuThreads - 16;
}
