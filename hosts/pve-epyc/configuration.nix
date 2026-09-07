{
  config,
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

    ../../nixos/client-apps/gnupg.nix
    ../../nixos/client-apps/vscode-remote-env.nix
    ../../nixos/client-components/impermanence.nix
    ../../nixos/optional-apps/archivebox.nix
    ../../nixos/optional-apps/archiveteam.nix
    ../../nixos/optional-apps/asf.nix
    ../../nixos/optional-apps/calibre-cops.nix
    ../../nixos/optional-apps/clamav.nix
    ../../nixos/optional-apps/clawemail.nix
    ../../nixos/optional-apps/dlx.nix
    ../../nixos/optional-apps/epic-awesome-gamer
    ../../nixos/optional-apps/fastapi-dls.nix
    ../../nixos/optional-apps/glauth.nix
    ../../nixos/optional-apps/handbrake-server.nix
    ../../nixos/optional-apps/handbrake-server.nix
    # ../../nixos/optional-apps/hydra
    ../../nixos/optional-apps/immich.nix
    ../../nixos/optional-apps/iyuuplus.nix
    ../../nixos/optional-apps/librechat.nix
    ../../nixos/optional-apps/llama-cpp.nix
    ../../nixos/optional-apps/llama-cpp.nix
    ../../nixos/optional-apps/llama-swap.nix
    ../../nixos/optional-apps/metapi.nix
    ../../nixos/optional-apps/microsoft-rewards-script.nix
    ../../nixos/optional-apps/mtranserver
    ../../nixos/optional-apps/n8n
    ../../nixos/optional-apps/ncps-client.nix
    ../../nixos/optional-apps/ncps-client.nix
    ../../nixos/optional-apps/netns-tnl-buyvm.nix
    ../../nixos/optional-apps/nfs.nix
    ../../nixos/optional-apps/nginx-openspeedtest.nix
    ../../nixos/optional-apps/opencl.nix
    # ../../nixos/optional-apps/picoclaw.nix
    ../../nixos/optional-apps/resin.nix
    ../../nixos/optional-apps/searxng.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/syncthing
    ../../nixos/optional-apps/tachidesk.nix
    ../../nixos/optional-apps/uni-api.nix
    ../../nixos/optional-apps/vlmcsd.nix
    ../../nixos/optional-apps/webdav.nix

    ../../nixos/optional-cron-jobs/ncmm.nix
    ../../nixos/optional-cron-jobs/qbittorrent-pt-cleanup
    ../../nixos/optional-cron-jobs/radicale-calendar-sync.nix
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

  services.calibre-cops.libraryPath = "/mnt/storage/media/Calibre Library";

  services.printing = {
    browsing = true;
    defaultShared = true;
    listenAddresses = [
      "127.0.0.1:631"
      "192.168.0.2:631"
    ];
    allowFrom = [ "all" ];
  };

  lantian.immich.storage = "/mnt/storage/immich";
  lantian.syncthing.storage = "/mnt/storage/media";
  lantian.archivebox.storage = "/mnt/storage/archivebox";

  lantian.nginxVhosts."ha.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://192.168.1.101:8123";
        proxyWebsockets = true;
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };

  # Allow Radicale calendar sync task to access *arr config
  systemd.services.radicale-calendar-sync.serviceConfig = {
    AmbientCapabilities = [ "CAP_DAC_OVERRIDE" ];
    CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];
  };
}
