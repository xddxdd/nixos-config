{
  ...
}:

{
  imports = [
    ../../nixos/server.nix

    ../../nixos/optional-apps/ndppd.nix

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = "yes";
    };
    ipv6AcceptRAConfig = {
      Token = "::1";
      DHCPv6Client = "no";
    };
    matchConfig.Name = "eth0";
  };

  services.ndppd.proxies.eth0.rules."2001:bc8:1640:4f1f::/64".method = "static";

  services.route-chain.routes = [
    "2001:bc8:1640:4f1f::1/120"
  ];

  services.yggdrasil.regions = [
    "germany"
    "france"
    "luxembourg"
    "netherlands"
    "united-kingdom"
  ];
}
