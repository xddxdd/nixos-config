{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix

    ../../nixos/common-apps/nginx
    ../../nixos/client-apps/gnupg.nix
    ../../nixos/client-components/impermanence.nix

    ../../nixos/optional-apps/handbrake-server.nix
    ../../nixos/optional-apps/llama-cpp.nix
    ../../nixos/optional-apps/ncps-client.nix
    ../../nixos/optional-apps/nix-distributed.nix
    ../../nixos/optional-apps/opencl.nix
    ../../nixos/optional-apps/picoclaw.nix
    # ../../nixos/optional-apps/sakura-llm
  ];

  environment.systemPackages = [
    pkgs.comfy-ui-cuda
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
}
