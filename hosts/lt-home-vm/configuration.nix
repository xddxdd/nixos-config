{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
    ./media-center.nix
    ./shares.nix

    ../../nixos/client-components/cups.nix

    ../../nixos/optional-apps/archiveteam.nix
    ../../nixos/optional-apps/asf.nix
    ../../nixos/optional-apps/btrbk-server.nix
    ../../nixos/optional-apps/calibre-cops.nix
    # ../../nixos/optional-apps/clamav.nix
    ../../nixos/optional-apps/glauth.nix
    # ../../nixos/optional-apps/homepage-dashboard.nix
    ../../nixos/optional-apps/immich.nix
    ../../nixos/optional-apps/iperf3.nix
    ../../nixos/optional-apps/iyuuplus.nix
    ../../nixos/optional-apps/mtranserver.nix
    ../../nixos/optional-apps/navidrome.nix
    ../../nixos/optional-apps/netns-tnl-buyvm.nix
    ../../nixos/optional-apps/nginx-openspeedtest.nix
    ../../nixos/optional-apps/ollama.nix
    ../../nixos/optional-apps/open-webui
    ../../nixos/optional-apps/opencl.nix
    # ../../nixos/optional-apps/palworld.nix
    ../../nixos/optional-apps/searxng.nix
    ../../nixos/optional-apps/sftp-server.nix
    ../../nixos/optional-apps/sillytavern.nix
    # ../../nixos/optional-apps/stable-diffusion-webui.nix
    ../../nixos/optional-apps/syncthing.nix
    ../../nixos/optional-apps/tachidesk.nix
    ../../nixos/optional-apps/uni-api
    ../../nixos/optional-apps/vlmcsd.nix
    ../../nixos/optional-apps/webdav.nix

    ../../nixos/optional-cron-jobs/oci-arm-host-capacity.nix
    ../../nixos/optional-cron-jobs/radicale-calendar-sync.nix
    ../../nixos/optional-cron-jobs/rsgain-cloudmusic.nix
  ];

  environment.systemPackages = [
    pkgs.hashcat
  ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 16;
    verbosity = "crit";
    extraOptions = [
      "--loadavg-target"
      "4"
      "--workaround-btrfs-send"
    ];
  };

  # # Disabled for heavy IO use
  # services.beesd.filesystems.storage = {
  #   spec = config.fileSystems."/mnt/storage".device;
  #   hashTableSizeMB = 128;
  #   verbosity = "crit";
  #   extraOptions = [
  #     "--loadavg-target"
  #     "4"
  #     "--workaround-btrfs-send"
  #   ];
  # };

  services.calibre-cops.libraryPath = "/mnt/storage/media/Calibre Library";

  # Rename to LAN to apply correct firewall rules
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{device/vendor}=="0x1af4", ATTR{device/device}=="0x0001",NAME="lan0"
  '';

  systemd.network.networks.lan0 = {
    address = [ "192.168.1.10/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "lan0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::10";
      DHCPv6Client = "no";
    };
    routes = [
      {
        Destination = "64:ff9b::/96";
        Gateway = "_ipv6ra";
      }
    ];
  };

  services.avahi.enable = lib.mkForce true;
  services.printing = {
    browsing = true;
    defaultShared = true;
    listenAddresses = [
      "127.0.0.1:631"
      "192.168.1.10:631"
    ];
    allowFrom = [ "all" ];
  };

  lantian.immich.storage = "/mnt/storage/immich";
  lantian.syncthing.storage = "/mnt/storage/media";
  lantian.btrbk.storage = "/mnt/storage/backups/btrbk";

  services.ollama.models = "/mnt/storage/ollama";
  systemd.tmpfiles.rules = [
    "d ${config.services.ollama.models} 755 ${config.services.ollama.user} ${config.services.ollama.group}"
  ];

  # Allow Radicale calendar sync task to access *arr config
  systemd.services.radicale-calendar-sync.serviceConfig = {
    AmbientCapabilities = [ "CAP_DAC_OVERRIDE" ];
    CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];
  };

  services."route-chain" = {
    enable = true;
    routes = [ "172.22.76.97/29" ];
  };
}
