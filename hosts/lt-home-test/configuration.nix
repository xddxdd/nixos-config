{ lib, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix

    ../../nixos/common-apps/nginx

    ../../nixos/client-components/tlp.nix

    ../../nixos/server-components/backup.nix
    ../../nixos/server-components/logging.nix

    # ../../nixos/optional-apps/llama-cpp-qwen3-reranker.nix
    ../../nixos/optional-apps/ollama.nix
    ../../nixos/optional-apps/vlmcsd.nix
  ];

  boot.kernelParams = [ "pci=realloc,assign-busses" ];

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

  services.fwupd.enable = true;

  services.tlp.settings = lib.mapAttrs (n: lib.mkForce) {
    TLP_DEFAULT_MODE = "BAT";
    TLP_PERSISTENT_DEFAULT = 1;
  };
}
