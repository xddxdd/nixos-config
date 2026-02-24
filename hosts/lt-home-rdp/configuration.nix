{
  lib,
  LT,
  config,
  ...
}:
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/ncps-client.nix
    ../../nixos/optional-apps/nix-distributed.nix
    ../../nixos/optional-apps/ollama.nix
    ../../nixos/optional-apps/opencl.nix
    # ../../nixos/optional-apps/sakura-llm
    ../../nixos/optional-apps/sunshine.nix
  ];

  networking.networkmanager.enable = lib.mkForce false;

  systemd.network.networks.eth0 = {
    address = [ "192.168.1.13/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "eth0";
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

  fileSystems."/mnt/share" = {
    device = "${LT.hosts."lt-home-vm".ltnet.IPv4}:/storage";
    fsType = "nfs";
    # Use automount to handle case when ZeroTier starts slow
    options = [
      "_netdev"
      "noatime"
      "noauto"
      "clientaddr=${LT.this.ltnet.IPv4}"
      "hard"
      "vers=4.2"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };

  services.ollama = {
    models = "/mnt/share/ollama";
    user = lib.mkForce "lantian";
    group = lib.mkForce "lantian";
  };
  systemd.tmpfiles.settings = {
    ollama = {
      "/mnt/share/ollama".d = {
        mode = "755";
        inherit (config.services.ollama) user group;
      };
    };
  };
  systemd.services.ollama = {
    requires = [ "mnt-share.mount" ];
    after = [ "mnt-share.mount" ];
  };
}
