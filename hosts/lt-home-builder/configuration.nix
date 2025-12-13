{ ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ../../nixos/optional-cron-jobs/nix-cachyos-kernel-build.nix
    # ../../nixos/optional-cron-jobs/nur-packages-build.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "192.168.1.12/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "eth0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::12";
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
